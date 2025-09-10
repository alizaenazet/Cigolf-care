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
    @State private var selectedContext: SelectedContext?
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading…")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let report = viewModel.report {
                ScrollView {
                    VStack(spacing: 20) {
                        ForemanCard(report: report) {
                            withAnimation {
                                showApprovalPopup = true
                            }
                        }
                        
                        ForEach(report.divisions) { division in
                            DivisionCard(division: division, isReportApproved: report.approved.isApproved) { div, loc in
                                if let foreman = ForemanMenu.fromId(foremanId) {
                                    selectedContext = SelectedContext(division: div, location: loc, foreman: foreman)
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                Text("No data available")
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: foremanId) {
            await viewModel.fetchReport(for: foremanId)
            viewModel.startRefetching()
        }
        .onDisappear{
            viewModel.stopRefetching()
        }
        
        .background(Color(.systemGray6))
        .sheet(isPresented: $showApprovalPopup) {
            if let report = viewModel.report {
                if SessionManager.shared.isLoggedIn {
                    if SessionManager.shared.userRole != "Mandor" {
                        ApprovalPopup(
                            date: DateHelper.formattedDate(report.createdAt),
                            provider: report.outsourceCompany!,
                            finishedCount: report.finishedTasks!,
                            totalCount: report.totalTasks!,
                            inProgressCount: report.pendingTasks!,
                            onApprove: {
                                Task {
                                    await viewModel.approveReport(for: foremanId, taskId: report.id)
                                    withAnimation { showApprovalPopup = false }
                                }
                            },
                            onClose: {
                                withAnimation { showApprovalPopup = false }
                            }
                        )
                        .transition(.opacity.combined(with: .scale))
                        .presentationDetents([.medium, .large])
                        .interactiveDismissDisabled(true)
                        .presentationCornerRadius(24)
                    }
                    else {
                        Text("You don't have permission to view this report.")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(item: $selectedContext) { context in
            AddTaskPopup(
                isPresented: Binding(
                    get: { selectedContext != nil },
                    set: { if !$0 { selectedContext = nil } }
                ),
                division: context.division,
                location: context.location,
                foreman: context.foreman,
                onSubmit: { jobType, area, priority, description in
                    Task {
                        await viewModel.addNewDailyTask(
                            for: foremanId,
                            taskId: viewModel.report?.id ?? 0,
                            divisionId: context.division.id,
                            locationId: context.location.id,
                            jobType: jobType,
                            area: area,
                            priority: priority,
                            description: description
                        )
                        selectedContext = nil
                        await viewModel.fetchReport(for: foremanId) // refresh
                    }
                },
                onClose: {
                    selectedContext = nil
                }
            )
            .transition(.opacity.combined(with: .scale))
            .presentationDetents([.large])
            .interactiveDismissDisabled(true)
            .presentationCornerRadius(24)
        }
    }
}

//#Preview {
//    DashboardView()
//}

