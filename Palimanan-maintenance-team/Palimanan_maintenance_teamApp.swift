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
  //Connect the SwiftUI app to the UIKit app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NetworkApi())
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
