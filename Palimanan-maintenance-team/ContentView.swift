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
        Group {
            if session.isLoggedIn {
                switch session.userRole {
                case "Admin", "Supervisor":
                    SupervisorDashboardView()
                case "Mandor":
                    ForemanDashboardView()
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



#Preview {
    ContentView()
}
