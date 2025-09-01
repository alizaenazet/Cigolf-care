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
    @State private var showApprovalPopup = false
    @State private var showAddTaskPopup = false
    @State private var selectedDivision: Division?
    @State private var selectedLocation: Location?
    
    var body: some View {
        ZStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading…")
                        .padding()
                } else if let report = viewModel.report {
                    VStack(spacing: 20) {
                        ForemanCard(report: report) {
                            withAnimation {
                                showApprovalPopup = true
                            }
                        }
                        
                        ForEach(report.divisions) { division in
                            DivisionCard(division: division) { div, loc in
                                selectedDivision = div
                                selectedLocation = loc
                                withAnimation { showAddTaskPopup = true }
                            }
                        }
                    }
                    .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    Text("No data available")
                        .foregroundStyle(.secondary)
                }
            }
            .task {
                // Important: fetch again when the foremanId changes
                await viewModel.fetchReport(for: foremanId)
            }
            .background(Color(.systemGray6))
            //            .sheet(isPresented: $viewModel.showAddTaskPopup) {
            //                if let division = viewModel.selectedDivision,
            //                   let location = viewModel.selectedLocation,
            //                   let foreman = ForemanMenu.fromId(foremanId) {
            //                    AddTaskPopup(
            //                        isPresented: $viewModel.showAddTaskPopup,
            //                        division: division,
            //                        location: location,
            //                        foreman: foreman
            //                    )
            //                }
            //            }
            
            if showAddTaskPopup,
               let division = selectedDivision,
               let location = selectedLocation,
               let foreman = ForemanMenu.fromId(foremanId) {
                AddTaskPopup(
                    isPresented: $showAddTaskPopup,
                    division: division,
                    location: location,
                    foreman: foreman
                )
                .transition(.opacity.combined(with: .scale))
            }
            
            // 👇 Overlay popup if state is true
            if showApprovalPopup, var report = viewModel.report {
                ApprovalPopup(
                    date: DateHelper.formattedDate(report.createdAt),
                    provider: report.outsourceCompany,
                    finishedCount: report.finishedTasks,
                    totalCount: report.totalTasks,
                    inProgressCount: report.pendingTasks,
                    onApprove: {
                        report.approved.isApproved = true
                        withAnimation { showApprovalPopup = false }
                    },
                    onClose: {
                        withAnimation { showApprovalPopup = false }
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

//#Preview {
//    DashboardView()
//}

