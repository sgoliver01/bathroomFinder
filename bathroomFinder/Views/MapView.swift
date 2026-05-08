//
//  MapView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import SwiftUI
import MapKit
import FirebaseFirestoreSwift
import Firebase

struct MapView: View {
    // MARK: - Properties
    @EnvironmentObject var locationManager: LocationManager
    @State private var bathrooms: [Bathroom] = []
    @State private var cachedBathroomIds: Set<String> = []  // track what we've already fetched
    @State var bathroom: Bathroom
    
    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedBathroom: Bathroom?
    @State private var visibleRegion: MKCoordinateRegion?
    
    // Search state
    @State private var searchResults: [MKMapItem] = []
    @State private var searchText = ""
    
    // UI state
    @State private var radiusMiles: Double = 1.0
    @State private var sliderValue: Double = 0.0
    @State private var selectedPlace: MKMapItem?
    @State private var navigateToRate = false
    @State private var bathroomToRate = Bathroom()
    @State private var minimumRating: Int = 0
    @State private var showFilterSheet = false
    @State private var showSearchBar = false
    @State private var fetchTimer: Timer?
    @State private var lastFetchedRegion: MKCoordinateRegion?
    
    let maxResults = 2000
    
    // MARK: - Computed Properties
    var filteredBathrooms: [Bathroom] {
        var results = bathrooms
        
        // Only show bathrooms visible on the map
        if let region = visibleRegion {
            let minLat = region.center.latitude - region.span.latitudeDelta / 2
            let maxLat = region.center.latitude + region.span.latitudeDelta / 2
            let minLon = region.center.longitude - region.span.longitudeDelta / 2
            let maxLon = region.center.longitude + region.span.longitudeDelta / 2
            results = results.filter {
                $0.latitude >= minLat && $0.latitude <= maxLat &&
                $0.longitude >= minLon && $0.longitude <= maxLon
            }
        }
        
        // Apply rating filter
        if minimumRating > 0 {
            results = results.filter { $0.averageRatingValue >= Double(minimumRating) }
        }
        
        return results
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- MAP ---
                Map(position: $mapPosition) {
                    UserAnnotation()
                    
                    // Toilet icons for rated bathrooms
                    ForEach(filteredBathrooms) { bathroom in
                        Annotation(bathroom.name, coordinate: bathroom.coordinate) {
                            Button {
                                selectedBathroom = bathroom
                            } label: {
                                Image(systemName: "toilet.fill")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                    .padding(4)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    
                    // Search result pins
                    ForEach(searchResults, id: \.self) { item in
                        Marker(item.name ?? "Place", coordinate: item.placemark.coordinate)
                            .tint(.orange)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .frame(height: 300)
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleRegion = context.region
                    debouncedFetch(context.region)
                }
                
                // --- SEARCH BAR (toggleable) ---
                if showSearchBar {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search potential bathrooms nearby...", text: $searchText)
                            .onSubmit { searchNearby() }
                        if !searchText.isEmpty {
                            Button { 
                                searchText = ""
                                searchResults = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Text("Find places that may have a bathroom you can use (hotels, coffee shops etc) — and give them a rating if they do!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // --- RESULTS LIST ---
                List {
                    // Search results section
                    if !searchResults.isEmpty {
                        Section(header: Text("Potential Bathrooms")) {
                            ForEach(searchResults, id: \.self) { item in
                                Button {
                                    selectedPlace = item
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(item.name ?? "Unknown")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(item.placemark.formattedAddress)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Rated bathrooms section
                    Section(header: Text("Bathrooms Nearby")) {
                        if filteredBathrooms.isEmpty {
                            Text("No bathrooms in this area")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(filteredBathrooms) { bathroom in
                                Button {
                                    // Center map on this bathroom
                                    mapPosition = .region(MKCoordinateRegion(
                                        center: bathroom.coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500
                                    ))
                                    // Open the detail sheet
                                    selectedBathroom = bathroom
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(bathroom.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(bathroom.address)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        if bathroom.reviewCountValue > 0 {
                                            VStack(spacing: 2) {
                                                Text(String(format: "%.1f", bathroom.averageRatingValue))
                                                    .font(.headline)
                                                    .bold()
                                                Text("💩")
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .listSectionSpacing(0)
            }
            .navigationTitle("Find Bathrooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation { showSearchBar.toggle() }
                        } label: {
                            Image(systemName: showSearchBar ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                        }
                        
                        Button {
                            showFilterSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: (minimumRating > 0 || radiusMiles != 1) ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                if minimumRating > 0 {
                                    Text("\(minimumRating)+💩")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
            // --- PLACE INFO CARD (search result tapped) ---
            .sheet(item: $selectedPlace) { place in
                VStack(alignment: .leading, spacing: 12) {
                    Text(place.name ?? "Unknown Place")
                        .font(.title2)
                        .bold()
                    
                    Text(place.placemark.formattedAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let phone = place.phoneNumber {
                        Label(phone, systemImage: "phone")
                            .font(.subheadline)
                    }
                    
                    Button {
                        var bathroom = Bathroom()
                        bathroom.name = place.name ?? ""
                        bathroom.address = place.placemark.formattedAddress
                        bathroom.latitude = place.placemark.coordinate.latitude
                        bathroom.longitude = place.placemark.coordinate.longitude
                        bathroomToRate = bathroom
                        selectedPlace = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            navigateToRate = true
                        }
                    } label: {
                        Label("Add Rating", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .presentationDetents([.height(220)])
            }
            // --- RATED BATHROOM SELECTED (toilet icon tapped) ---
            .sheet(item: $selectedBathroom) { bathroom in
                NavigationStack {
                    BathroomDetailView(bathroom: bathroom, presentedAsSheet: true)
                        .environmentObject(BathroomViewModel())
                        .environmentObject(locationManager)
                }
                .presentationDetents([.medium, .large])
            }
            // --- RATE VIA NAVIGATION ---
            .navigationDestination(isPresented: $navigateToRate) {
                ReviewView(bathroom: bathroomToRate, review: Review(), canDismiss: true)
                    .environmentObject(BathroomViewModel())
            }
            // --- FILTER SHEET ---
            .sheet(isPresented: $showFilterSheet) {
                VStack(spacing: 20) {
                    Text("Filter Bathrooms")
                        .font(.headline)
                    
                    // Radius
                    VStack(spacing: 4) {
                        Text("Radius: \(Int(radiusMiles)) miles")
                            .font(.subheadline)
                            .bold()
                        Slider(value: $sliderValue, in: 0...1)
                            .onChange(of: sliderValue) { _, val in
                                // Exponential: 1 mile at 0, 10 miles at 1
                                radiusMiles = 1 + 9 * pow(val, 2)
                            }
                    }
                    
                    Divider()
                    
                    // Minimum rating
                    VStack(spacing: 4) {
                        Text("Minimum Rating")
                            .font(.subheadline)
                            .bold()
                        PoopsSelectionView(rating: $minimumRating)
                        if minimumRating > 0 {
                            Text("Showing \(minimumRating)+ 💩 only")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button("Clear All") {
                            minimumRating = 0
                            sliderValue = 0
                            radiusMiles = 1
                        }
                        .foregroundColor(.red)
                        
                        Button("Done") {
                            showFilterSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(24)
                .presentationDetents([.height(350)])
                .onChange(of: radiusMiles) { _, _ in
                    if let location = locationManager.location?.coordinate {
                        let meters = radiusMiles * 1609.34 * 2
                        mapPosition = .region(MKCoordinateRegion(
                            center: location,
                            latitudinalMeters: meters,
                            longitudinalMeters: meters
                        ))
                    }
                }
            }
            .onAppear {
                if let location = locationManager.location?.coordinate {
                    let region = MKCoordinateRegion(center: location, latitudinalMeters: 3000, longitudinalMeters: 3000)
                    fetchBathroomsInRegion(region)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .reviewSaved)) { _ in
                if let region = visibleRegion {
                    lastFetchedRegion = nil  // force re-fetch
                    fetchBathroomsInRegion(region)
                }
            }
        }
    }
    
    // MARK: - Search
    func searchNearby() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        if let location = locationManager.location?.coordinate {
            request.region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: radiusMiles * 1609.34 * 2,
                longitudinalMeters: radiusMiles * 1609.34 * 2
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "unknown")")
                return
            }
            searchResults = response.mapItems
        }
    }
    
    // MARK: - Debounced Fetch
    func debouncedFetch(_ region: MKCoordinateRegion) {
        // Cancel any pending fetch
        fetchTimer?.invalidate()
        
        // Check if region changed significantly (cache hit = skip)
        if let last = lastFetchedRegion {
            let latDiff = abs(region.center.latitude - last.center.latitude)
            let lonDiff = abs(region.center.longitude - last.center.longitude)
            let spanDiff = abs(region.span.latitudeDelta - last.span.latitudeDelta)
            
            // Skip if moved less than ~10% of the visible area
            if latDiff < last.span.latitudeDelta * 0.1 &&
               lonDiff < last.span.longitudeDelta * 0.1 &&
               spanDiff < last.span.latitudeDelta * 0.2 {
                return
            }
        }
        
        // Debounce: wait 0.8s before fetching
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
            DispatchQueue.main.async {
                fetchBathroomsInRegion(region)
                lastFetchedRegion = region
            }
        }
    }
    
    // MARK: - Fetch Bathrooms in Visible Region
    func fetchBathroomsInRegion(_ region: MKCoordinateRegion) {
        let db = Firestore.firestore()
        
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2
        
        db.collection("bathrooms")
            .whereField("latitude", isGreaterThanOrEqualTo: minLat)
            .whereField("latitude", isLessThanOrEqualTo: maxLat)
            .limit(to: 500)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let centerLat = region.center.latitude
                let centerLon = region.center.longitude
                
                // Filter longitude and sort by distance from center
                let results = documents.compactMap { try? $0.data(as: Bathroom.self) }
                    .filter { $0.longitude >= minLon && $0.longitude <= maxLon }
                    .sorted { a, b in
                        let distA = abs(a.latitude - centerLat) + abs(a.longitude - centerLon)
                        let distB = abs(b.latitude - centerLat) + abs(b.longitude - centerLon)
                        return distA < distB
                    }
                
                DispatchQueue.main.async {
                    // Accumulate — only add bathrooms we haven't seen before
                    for bathroom in results.prefix(maxResults) {
                        if let id = bathroom.id, !cachedBathroomIds.contains(id) {
                            cachedBathroomIds.insert(id)
                            bathrooms.append(bathroom)
                        }
                    }
                    
                    // Cap total cache size
                    if bathrooms.count > maxResults {
                        // Remove oldest (first added) to stay under cap
                        let overflow = bathrooms.count - maxResults
                        let removed = bathrooms.prefix(overflow)
                        for b in removed { cachedBathroomIds.remove(b.id ?? "") }
                        bathrooms.removeFirst(overflow)
                    }
                }
            }
    }
    
}

// MARK: - MKMapItem Identifiable
extension MKMapItem: @retroactive Identifiable {
    public var id: String {
        "\(placemark.coordinate.latitude),\(placemark.coordinate.longitude),\(name ?? "")"
    }
}

// MARK: - CLPlacemark helper
extension CLPlacemark {
    var formattedAddress: String {
        var result = ""
        if let number = subThoroughfare { result += number + " " }
        if let street = thoroughfare { result += street }
        if let city = locality {
            result = result.isEmpty ? city : result + ", " + city
        }
        if let state = administrativeArea {
            result = result.isEmpty ? state : result + ", " + state
        }
        return result.isEmpty ? "No address available" : result
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MapView(bathroom: Bathroom())
            .environmentObject(LocationManager())
    }
}
