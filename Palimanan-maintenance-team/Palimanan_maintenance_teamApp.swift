//
//  Palimanan_maintenance_teamApp.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 28/08/25.
//

import SwiftUI
import OneSignalFramework

class NetworkApi: ObservableObject {
    let apiVersion = "v1"
    let baseUrl = "https://db7717e5-b4ac-4078-b573-874fe49ddf89.mock.pstmn.io/api/\( "v1" )"
}

@main
struct Palimanan_maintenance_teamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var session: SessionManager
    
    init() {
        // 1. We create ONE instance of SessionManager.
        let sessionManagerInstance = SessionManager()
        
        // 2. We use a special syntax to initialize the @StateObject with our instance.
        // This makes the UI own this single source of truth.
        _session = StateObject(wrappedValue: sessionManagerInstance)
        
        // 3. We assign that SAME instance to the static 'shared' variable.
        // Now, APIService.shared.logout() will call the logout() method on the
        // exact same object that the UI is observing.
        SessionManager.shared = sessionManagerInstance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NetworkApi())
                .environmentObject(session) // We pass the single source of truth to the UI.
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

       // Enable verbose logging for debugging (remove in production)
       OneSignal.Debug.setLogLevel(.LL_VERBOSE)
       // Initialize with your OneSignal App ID
       OneSignal.initialize("cdf0877f-177f-42fd-8bb5-c6305d6242ec", withLaunchOptions: launchOptions)
       // Use this method to prompt for push notifications.
       // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
       OneSignal.Notifications.requestPermission({ accepted in
         print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: false)

       return true
    }
}
