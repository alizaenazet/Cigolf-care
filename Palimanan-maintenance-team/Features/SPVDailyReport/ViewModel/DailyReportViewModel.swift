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
    @Published var locationMap: [String: Int] = [
        "All": 1,
        "Green": 2,
        "Tee Box": 3,
        "Fairway": 4,
        "Apron": 5,
        "Rough": 6,
        "Bunker": 7,
        "Nursery": 8,
        "Driving Range": 9,
        "Maingate": 10,
        "Putting 10": 11,
        "Paving Room": 12,
        "Resto": 13,
        "Mekanik": 14,
        "Irigasi": 15
    ]
    @Published var dayMap: [String: String] = [
        "Minggu": "sunday",
        "Senin": "monday",
        "Selasa": "tueday",
        "Rabu": "wednesday",
        "Kamis": "thursday",
        "Jumat": "friday",
        "Sabtu": "saturday",
    ]
    
    init() {
        
//        cigolfLocation.append(contentsOf: [
//            CigolfLocation(id: 1, name: "All"),
//            CigolfLocation(id: 2, name: "Green", isSelected: true),
//            CigolfLocation(id: 3, name: "Tee Box", isSelected: true),
//            CigolfLocation(id: 4, name: "Fairway"),
//            CigolfLocation(id: 5, name: "Apron"),
//            CigolfLocation(id: 6, name: "Rough"),
//            CigolfLocation(id: 7, name: "Bunker"),
//            CigolfLocation(id: 8, name: "Nursery"),
//            CigolfLocation(id: 9, name: "Driving Range"),
//            CigolfLocation(id: 10, name: "Maingate"),
//            CigolfLocation(id: 11, name: "Putting 10"),
//            CigolfLocation(id: 12, name: "Paving Room"),
//            CigolfLocation(id: 13, name: "Resto"),
//            CigolfLocation(id: 14, name: "Mekanik"),
//            CigolfLocation(id: 15, name: "Irigasi"),
//        ])
//        cigolfLocation[1].jobs = Array(repeating: DailyJob(), count: 2)
//        cigolfLocation[2].jobs = Array(repeating: DailyJob(), count: 2)
        
        cigolfDivision.append(contentsOf: [
            CigolfDivision(id: 1, name: "Operasional", isSelected: true),
            CigolfDivision(id: 2, name: "Landscape", isSelected: true),
            CigolfDivision(id: 3, name: "Projek"),
            CigolfDivision(id: 4, name: "Irigasi"),
            CigolfDivision(id: 5, name: "Mekanik"),
        ])
        
        addLocation(id: 0)
        
        addLocation(id: 1)
    }
    
    func addDivision() {
        if let index = cigolfDivision.firstIndex(where: { !$0.isSelected }) {
            cigolfDivision[index].isSelected = true
            addLocation(id: index)
            
            //            if cigolfDivision[index].jobs.isEmpty {
            //                cigolfDivision[index].jobs = Array(repeating: DailyJob(), count: 3)
            //            }
            print("Divisi ditambahkan:", cigolfDivision[index].name)
        } else {
            print("Semua divisi sudah dipilih")
        }
    }
    
    func addJob(divId: Int, locId: Int) {
        print(divId)
        print(locId)
        print(cigolfDivision[divId].name)
        print(cigolfDivision[divId].locations[locId].name)
        cigolfDivision[divId].locations[locId].jobs.append(DailyJob())
    }
    
    func addLocation(id: Int) {
        cigolfDivision[id].locations.append(CigolfLocation(id: cigolfLocation.count + 1))
        cigolfDivision[id].locations[cigolfDivision[id].locations.count - 1].jobs.append(DailyJob())
        cigolfDivision[id].locations[cigolfDivision[id].locations.count - 1].jobs.append(DailyJob())
        
//        if let index = cigolfDivision[id].locations.firstIndex(where: { !$0.isSelected }) {
//            cigolfDivision[id].locations[index].isSelected = true
//            
//            //            if cigolfDivision[id].locations.isEmpty {
//            //                cigolfDivision[id].locations = Array(repeating: CigolfLocation(), count: 3)
//            //            }
//            print("Lokasi ditambahkan:", cigolfDivision[id].locations[index].name)
//        } else {
//            print("Semua lokasi sudah dipilih")
//        }
    }
    
    func isSelectedAllLocation(id: Int) -> Bool {
        return cigolfDivision[id].locations.allSatisfy { $0.isSelected }
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
