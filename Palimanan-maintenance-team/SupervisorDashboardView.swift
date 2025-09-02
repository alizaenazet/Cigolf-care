//
//  SupervisorDashboardView.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import SwiftUI

struct SupervisorDashboardView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack {
            Text("Welcome, \(session.userRole ?? "No Role Found")!")
                .font(.largeTitle)
            Text("Token: \(session.accessToken ?? "No Token Found")")
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: 250)
            Button("Logout") {
                session.logout()
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    SupervisorDashboardView()
}
