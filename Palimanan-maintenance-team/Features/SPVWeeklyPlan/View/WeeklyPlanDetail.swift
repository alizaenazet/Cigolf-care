//
//  WeeklyPlanDetail.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 01/09/25.
//

import SwiftUI

struct WeeklyPlanDetailView: View {
    @ObservedObject var viewModel: WeeklyPlanHistoryViewModel
    
    var body: some View {
        if viewModel.isLoading {
            VStack {
                ProgressView("Loading…")
                    .padding()
            }
            .frame(maxWidth: .infinity)
        } else if let detail = viewModel.weeklyPlanDetail {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: Header (Date Range)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Dari")
                            Text(detail.startAt.toDate()?.toIndonesianFormat() ?? "-")
                                .padding(6)
                                .background(Color(.systemGray3))
                                .cornerRadius(8)
                            Text("Hingga")
                            Text(detail.endAt.toDate()?.toIndonesianFormat() ?? "-")
                                .padding(6)
                                .background(Color(.systemGray3))
                                .cornerRadius(8)
                        }
                        .font(.subheadline)
                    }
                    .padding(.bottom, 8)
                    
                    // MARK: Divisions & Locations
                    ForEach(detail.divisions) { division in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(division.name)
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            ForEach(division.locations) { location in
                                WeeklyPlanLocationCard(location: location)
                                
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detail Program Mingguan")
            .background(Color(.systemGray6))
        } else {
            Text("Tidak ada detail")
                .foregroundColor(.secondary)
        }
    }
}

