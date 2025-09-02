//
//  DashboardView.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct DailyReportDetailView: View {
    @ObservedObject var viewModel: DailyReportViewModel
    @State private var showApprovalPopup = false
    @State private var selectedContext: SelectedContext?
    
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading…")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let report = viewModel.reportDetail {
                ScrollView {
                    VStack(spacing: 20) {
                        DailyRepForemanCard(report: report) {
                            withAnimation {
                                showApprovalPopup = true
                            }
                        }
                        
                        ForEach(report.divisions) { division in
                            DailyRepDivCard(division: division)
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
        
        .background(Color(.systemGray6))
        .sheet(isPresented: $showApprovalPopup) {
            if let report = viewModel.reportDetail {
                ApprovalPopup(
                    date: DateHelper.formattedDate(report.createdAt),
                    provider: report.outsourceCompany ?? "-",
                    finishedCount: report.finishedTasks ?? 0,
                    totalCount: report.totalTasks ?? 0,
                    inProgressCount: report.pendingTasks ?? 0,
                    onApprove: {
                        viewModel.reportDetail?.approved.isApproved = true
                        withAnimation { showApprovalPopup = false }
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
        }
    }
}

//#Preview {
//    DashboardView()
//}

