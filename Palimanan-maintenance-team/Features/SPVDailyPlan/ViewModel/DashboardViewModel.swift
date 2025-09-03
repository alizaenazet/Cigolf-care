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
    
    func approveReport(for foremanId: Int, taskId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let spvId: Int
            print("👤 Current user role: \(SessionManager.shared.userRole ?? "Unknown")")
            print("👤 Current user ID: \(SessionManager.shared.userId ?? -1)")
            if SessionManager.shared.userRole != "Mandor",
               let idString = SessionManager.shared.userId,
               let id: Int? = Int(idString) {
                spvId = id!
            } else {
                spvId = -1
            }
            print("📦 Approving report with foremanId: \(foremanId), taskId: \(taskId), spvId: \(spvId)")
            let response: NormalResponse = try await APIService.shared.post("/foreman/\(foremanId)/daily-task/\(taskId)/approve", parameters: ["spvId": spvId], responseType: NormalResponse.self)
            print("✅ Weekly plan created:", response.message)
            await fetchReport(for: foremanId)
        } catch {
            print("❌ Approve failed:", error) // 👈 log actual error
            if let afError = error.asAFError {
                print("🔍 Alamofire error:", afError.errorDescription ?? "")
            }
            self.errorMessage = "Failed to approve report: \(error.localizedDescription)"
        }
    }
}

