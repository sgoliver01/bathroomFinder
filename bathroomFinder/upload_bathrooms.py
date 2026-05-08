"""
Fetch public bathrooms from OpenStreetMap and upload to Firestore.
Run: pip install requests firebase-admin
Then: python3 upload_bathrooms.py
"""

import requests
import firebase_admin
from firebase_admin import credentials, firestore
import time

# --- CONFIGURE THIS ---
# Path to your Firebase service account key JSON
# Download from: Firebase Console → Project Settings → Service Accounts → Generate New Private Key
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"

# Cities to fetch bathrooms for
CITIES = {
    "New York City": {"lat": 40.7128, "lon": -74.0060, "radius": 15000},
    "San Francisco": {"lat": 37.7749, "lon": -122.4194, "radius": 10000},
    "Baltimore": {"lat": 39.2904, "lon": -76.6122, "radius": 10000},
    "Denver": {"lat": 39.7392, "lon": -104.9903, "radius": 10000},
}

# --- SETUP FIREBASE ---
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

def fetch_bathrooms_from_osm(city_name, lat, lon, radius):
    """Fetch public toilets from OpenStreetMap Overpass API."""
    query = f"""
    [out:json][timeout:60];
    (
      node["amenity"="toilets"](around:{radius},{lat},{lon});
      node["toilets"="yes"](around:{radius},{lat},{lon});
    );
    out body;
    """
    
    url = "https://overpass-api.de/api/interpreter"
    print(f"Fetching bathrooms for {city_name}...")
    
    response = requests.post(url, data={"data": query})
    if response.status_code != 200:
        print(f"  Error fetching {city_name}: {response.status_code}")
        return []
    
    data = response.json()
    elements = data.get("elements", [])
    print(f"  Found {len(elements)} bathrooms in {city_name}")
    return elements

def upload_to_firestore(elements, city_name):
    """Upload bathroom data to Firestore."""
    batch = db.batch()
    count = 0
    
    for element in elements:
        lat = element.get("lat")
        lon = element.get("lon")
        tags = element.get("tags", {})
        
        # Build a name from available tags
        name = tags.get("name", "")
        if not name:
            # Try to build a descriptive name
            if tags.get("operator"):
                name = f"{tags['operator']} Public Restroom"
            elif tags.get("description"):
                name = tags["description"]
            else:
                name = "Public Restroom"
        
        # Build address from tags
        street = tags.get("addr:street", "")
        housenumber = tags.get("addr:housenumber", "")
        address = f"{housenumber} {street}".strip() if street else city_name
        
        doc_data = {
            "name": name,
            "address": address,
            "latitude": lat,
            "longitutde": lon,  # matching your existing typo in Firestore
            "source": "openstreetmap",
            "city": city_name,
            "fee": tags.get("fee", "unknown"),
            "wheelchair": tags.get("wheelchair", "unknown"),
            "opening_hours": tags.get("opening_hours", ""),
        }
        
        # Use OSM node ID to prevent duplicates on re-run
        doc_ref = db.collection("bathrooms").document(f"osm_{element['id']}")
        batch.set(doc_ref, doc_data)
        count += 1
        
        # Firestore batches max at 500
        if count % 450 == 0:
            batch.commit()
            batch = db.batch()
            print(f"  Committed {count} so far...")
    
    if count % 450 != 0:
        batch.commit()
    
    print(f"  Uploaded {count} bathrooms for {city_name}")
    return count

def main():
    total = 0
    
    for city_name, coords in CITIES.items():
        elements = fetch_bathrooms_from_osm(
            city_name, coords["lat"], coords["lon"], coords["radius"]
        )
        
        if elements:
            count = upload_to_firestore(elements, city_name)
            total += count
        
        # Be nice to the Overpass API
        time.sleep(5)
    
    print(f"\nDone! Uploaded {total} total bathrooms across {len(CITIES)} cities.")

if __name__ == "__main__":
    main()
