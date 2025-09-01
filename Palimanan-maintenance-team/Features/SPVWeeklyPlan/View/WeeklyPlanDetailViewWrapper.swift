//
//  WeeklyPlanDetailViewWrapper.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 01/09/25.
//

import SwiftUI

struct WeeklyPlanDetailViewWrapper: View {
    @StateObject private var viewModel = WeeklyPlanHistoryViewModel()
    let weeklyId: Int
    
    var body: some View {
        WeeklyPlanDetailView(viewModel: viewModel)
            .task {
                await viewModel.fetchWeeklyPlanDetail(for: weeklyId)
            }
    }
}
