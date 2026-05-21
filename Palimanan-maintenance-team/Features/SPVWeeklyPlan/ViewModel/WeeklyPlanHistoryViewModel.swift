//
//  WeeklyPlanHistory.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 01/09/25.
//
import Foundation

@MainActor

class WeeklyPlanHistoryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var startAt = "2025-01-01".toDate() ?? Date()
    @Published var endAt = "2025-01-15".toDate() ?? Date()
    @Published var errorMessage: String?
    
    @Published var weeklyPlanHistoryPreview: [WeeklyPlanPreview] = []
    @Published var weeklyPlanDetail: WeeklyPlanDetail?
    
    
    func fetchLastWeeklyPlanHistory() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: WeeklyPlanPreviewResponse = try await APIService.shared.request(
                "/weekly-plan",
                responseType: WeeklyPlanPreviewResponse.self
            )
            // Properly assign the dates
            self.weeklyPlanHistoryPreview = response.data
            if let firstItem = response.data.first {
                self.endAt = firstItem.endDate ?? Date()
            }
            
            if let lastItem = response.data.last {
                self.startAt = lastItem.startDate ?? Date()
            }
            
        } catch {
            self.errorMessage = "Gagal Untuk Memuat Laporan: \(error.localizedDescription)"
        }
        
//        isLoading = false
    }
    
    func fetchLastWeeklyPlanHistoryByFilter() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: WeeklyPlanPreviewResponse = try await APIService.shared.request(
                "/weekly-plan",
                parameters: ["start_at": (startAt.toString()), "end_at": (endAt.toString())],
                responseType: WeeklyPlanPreviewResponse.self
            )
            self.weeklyPlanHistoryPreview = response.data
        } catch {
            print(error.localizedDescription)
            self.errorMessage = "Gagal Untuk Memuat Laporan: \(error.localizedDescription)"
        }
        
//        isLoading = false
    }
    
    func fetchWeeklyPlanDetail(for weeklyId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: WeeklyPlanDetailResponse = try await APIService.shared.request(
                "/weekly-plan/\(weeklyId)",
                responseType: WeeklyPlanDetailResponse.self
            )
            self.weeklyPlanDetail = response.data
        } catch {
            self.errorMessage = "Gagal Untuk Memuat Laporan: \(error.localizedDescription)"
        }
    }
}
