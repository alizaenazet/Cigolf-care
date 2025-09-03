//
//  WeeklyPlanDetailViewWrapper.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 01/09/25.
//

import SwiftUI

struct DailyReportDetailViewWrapper: View {
    @StateObject private var viewModel = DailyReportViewModel()
    let foremanId: Int
    let reportId: Int
    
    var body: some View {
        DailyReportDetailView(viewModel: viewModel, foremanId: foremanId)
            .task(id: reportId) {
                await viewModel.fetchReportDetail(for: foremanId, reportId: reportId)
            }
    }
}
