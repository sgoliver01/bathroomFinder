//
//  BathroomCache.swift
//  bathroomFinder
//

import Foundation
import MapKit

class BathroomCache: ObservableObject {
    @Published var bathrooms: [Bathroom] = []
    @Published var sessionReads: Int = 0
    var cachedBathroomIds: Set<String> = []
    var lastFetchedRegion: MKCoordinateRegion?
    
    let maxSessionReads = 1000
    let maxCacheSize = 2000
    
    var isAtReadLimit: Bool {
        sessionReads >= maxSessionReads
    }
    
    func addBathrooms(_ newBathrooms: [Bathroom]) {
        for bathroom in newBathrooms {
            if let id = bathroom.id, !cachedBathroomIds.contains(id) {
                cachedBathroomIds.insert(id)
                bathrooms.append(bathroom)
            }
        }
        
        // Cap cache size
        if bathrooms.count > maxCacheSize {
            let overflow = bathrooms.count - maxCacheSize
            let removed = bathrooms.prefix(overflow)
            for b in removed { cachedBathroomIds.remove(b.id ?? "") }
            bathrooms.removeFirst(overflow)
        }
    }
    
    func refreshAll(with newBathrooms: [Bathroom]) {
        bathrooms = []
        cachedBathroomIds = []
        addBathrooms(newBathrooms)
    }
    
    func countReads(_ count: Int) {
        sessionReads += count
    }
}
