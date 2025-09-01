//
//  DashboardViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//


import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var report: ForemanReport?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchReport(for foremanId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: DashboardResponse = try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task/latest-day",
                responseType: DashboardResponse.self
            )
            self.report = response.data
        } catch {
            self.errorMessage = "Failed to load report: \(error.localizedDescription)"
        }
    }
}

