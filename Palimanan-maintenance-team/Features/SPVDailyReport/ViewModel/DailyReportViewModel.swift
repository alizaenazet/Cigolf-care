//
//  DailyReportViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import Foundation

@MainActor
class DailyReportViewModel: ObservableObject {
    @Published var report: [DailyReport] = [] // di ViewModel
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchDailyReport(for foremanId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: DailyReportResponse = try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task",
                method: .get,
                responseType: DailyReportResponse.self
            )
            self.report = response.data
        } catch {
            self.errorMessage = "Failed to load report: \(error.localizedDescription)"
        }
    }
    
    func fetchDailyReportByDateRange(for foremanId: Int, startDate: String, endDate: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: DailyReportResponse = try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task?start_at=\(startDate)&end_at=\(endDate)",
                method: .get,
                responseType: DailyReportResponse.self
            )
            self.report = response.data
        } catch {
            self.errorMessage = "Failed to load report: \(error.localizedDescription)"
        }
    }
    
}
