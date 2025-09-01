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
            guard let url = URL(string: "https://db7717e5-b4ac-4078-b573-874fe49ddf89.mock.pstmn.io/api/v1/foreman/\(foremanId)/daily-task/latest-day")
            else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(DashboardResponse.self, from: data)
            
            self.report = response.data
        } catch {
            errorMessage = "Failed to load report: \(error.localizedDescription)"
        }
    }
}

