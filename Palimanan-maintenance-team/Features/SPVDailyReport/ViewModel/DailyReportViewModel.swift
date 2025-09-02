//
//  DailyReportViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import Foundation

@MainActor
class DailyReportViewModel: ObservableObject {
    @Published var report: [DailyReport] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cigolfDivision: [CigolfDivision] = []
    @Published var cigolfLocation: [CigolfLocation] = []
    
    init() {
        cigolfDivision.append(contentsOf: [
            CigolfDivision(id: 1, name: "Operasional", isSelected: true),
            CigolfDivision(id: 2, name: "Landscape", isSelected: true),
            CigolfDivision(id: 3, name: "Projek"),
            CigolfDivision(id: 4, name: "Irigasi"),
            CigolfDivision(id: 5, name: "Mekanik"),
        ])
        cigolfLocation.append(contentsOf: [
            CigolfLocation(id: 1, name: "All"),
            CigolfLocation(id: 2, name: "Green", isSelected: true),
            CigolfLocation(id: 3, name: "Tee Box", isSelected: true),
            CigolfLocation(id: 4, name: "Fairway"),
            CigolfLocation(id: 5, name: "Apron"),
            CigolfLocation(id: 6, name: "Rough"),
            CigolfLocation(id: 7, name: "Bunker"),
            CigolfLocation(id: 8, name: "Nursery"),
            CigolfLocation(id: 9, name: "Driving Range"),
            CigolfLocation(id: 10, name: "Maingate"),
            CigolfLocation(id: 11, name: "Putting 10"),
            CigolfLocation(id: 12, name: "Paving Room"),
            CigolfLocation(id: 13, name: "Resto"),
            CigolfLocation(id: 14, name: "Mekanik"),
            CigolfLocation(id: 15, name: "Irigasi"),
        ])
    }
    
    func addDivision() {
        if let index = cigolfDivision.firstIndex(where: { !$0.isSelected }) {
            cigolfDivision[index].isSelected = true
            print("Divisi ditambahkan:", cigolfDivision[index].name)
        } else {
            print("Semua divisi sudah dipilih")
        }
    }
    
    func isSelectedAllDivision() -> Bool {
        return cigolfDivision.allSatisfy { $0.isSelected }
    }
    
    func fetchDailyReport(for foremanId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: DailyReportResponse = try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task",
                method: .get,
                responseType: DailyReportResponse.self
            )
            self.report = response.data ?? []
        } catch {
            self.report = []
            //            self.errorMessage = "Failed to load report: \(error.localizedDescription)"
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
            self.report = response.data ?? []
        } catch {
            print(error.localizedDescription)
            self.errorMessage = "Failed to load report: \(error.localizedDescription)"
        }
    }
    
}
