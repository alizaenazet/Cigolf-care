//
//  DashboardView.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI


struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let foremanId: Int

    var body: some View {
//        Group {
//            if viewModel.isLoading {
//                ProgressView("Loading...")
//            } else if let error = viewModel.errorMessage {
//                Text(error).foregroundColor(.red)
//            } else if let report = viewModel.report {
//                ForemanCard(report: report)
//            } else {
//                Text("No data")
//            }
//        }
//        .task {
//            await viewModel.fetchReport(for: foremanId)
//        }
    }
}
