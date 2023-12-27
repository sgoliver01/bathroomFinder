//
//  bathroomFinderApp.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/22/23.
//

import SwiftUI

@main
struct bathroomFinderApp: App {
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationManager)
        }
    }
}
