//
//  ContentView.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 28/08/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        // Use a group to avoid needing 'if/else' inside the main body property
        Group {
            if session.isLoggedIn {
                // Let's check the user role received from the session
                switch session.userRole {
                
                // IMPORTANT: Change these strings to EXACTLY match what your API sends.
                // Example if API sends "Admin", "Supervisor", "Mandor"
                case "Admin", "Supervisor":
                    SupervisorDashboardView()
                case "Mandor":
                    ForemanDashboardView()
                    
                // Example if API sends "admin", "spv", "foreman"
                // case "admin", "spv":
                //     SupervisorDashboardView()
                // case "foreman":
                //     ForemanDashboardView()

                // THIS IS THE CRITICAL CHANGE:
                // Handle any unexpected roles by showing an error message.
                // This prevents the app from sending you back to LoginView for no reason.
                default:
                    VStack {
                        Text("Login Successful!")
                        Text("Error: Unknown user role.")
                        Text("Received Role: \(session.userRole ?? "Not Provided")")
                            .padding()
                        
                        Button("Logout") {
                            session.logout()
                        }
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}
