//
//  bathroomFinderApp.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/22/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct bathroomFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var locationManager = LocationManager()
    @StateObject var bathroomVM = BathroomViewModel()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
            //    HomeView()
                .environmentObject(locationManager)
                .environmentObject(bathroomVM)
            
            
        }
    }
}
