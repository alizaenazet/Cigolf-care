//
//  DailyReportViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import Foundation
import UIKit

@MainActor
class DailyReportViewModel: ObservableObject {
    @Published var report: [DailyReport] = []
    @Published var reportDetail: ForemanReport?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var successMessage = ""
    @Published var cigolfDivision: [CigolfDivision] = []
    @Published var cigolfLocation: [CigolfLocation] = []
    @Published var dailyProgramRequest: DailyProgramRequest?
    @Published var divisionRequests: [DivisionRequest] = []
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
    //    @Published var dayMap: [String: String] = [
    //        "Minggu": "sunday",
    //        "Senin": "monday",
    //        "Selasa": "tueday",
    //        "Rabu": "wednesday",
    //        "Kamis": "thursday",
    //        "Jumat": "friday",
    //        "Sabtu": "saturday",
    //    ]
    enum DailyProgramError: Error, LocalizedError {
        case locationNotSelected(String)   // pesan error lokasi
        case jobIncomplete(String)         // pesan error job
        
        var errorDescription: String? {
            switch self {
            case .locationNotSelected(let msg): return msg
            case .jobIncomplete(let msg): return msg
            }
        }
    }
    
    init() {
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
    
    func removeJob(divId: Int, locId: Int, jobId: UUID) {
        print(divId)
        print(locId)
        print(jobId)
        if let divIndex = cigolfDivision.firstIndex(where: { $0.id == divId }),
           let locIndex = cigolfDivision[divIndex].locations.firstIndex(where: { $0.id == locId }),
           let jobIndex = cigolfDivision[divIndex].locations[locIndex].jobs.firstIndex(where: { $0.id == jobId }) {
            cigolfDivision[divIndex].locations[locIndex].jobs.remove(at: jobIndex)
        }
    }
    
    func submitProgram(foremanId: Int) {
        do {
            let request = try formatToDailyProgramRequest()
            if let jsonData = try? JSONEncoder().encode(request),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
    
    func formatToDailyProgramRequest() throws -> DailyProgramRequest {
        self.dailyProgramRequest = nil
        self.divisionRequests = []
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        for division in cigolfDivision.filter({ $0.isSelected }) {
            for location in division.locations {
                // 🔴 validasi lokasi
                if location.id == 0 {
                    throw DailyProgramError.locationNotSelected(
                        "Ada lokasi yang belum dipilih pada divisi \(division.name)"
                    )
                }
                
                var tasks: [TaskRequest] = []
                for job in location.jobs {
                    let priority = Int(job.priority) ?? 0
                    
                    // 🔴 validasi job
                    guard !job.jobType.isEmpty,
                          !job.holes.isEmpty,
                          priority > 0,
                          !job.description.isEmpty else {
                        throw DailyProgramError.jobIncomplete(
                            "Wajib mengisi semua input pada divisi \(division.name) dan lokasi \(location.name)"
                        )
                    }
                    
                    let formattedHoles = job.holes.map { hole in
                            if let number = Int(hole) {
                                return "Hole \(number)"
                            } else {
                                return hole  // tetap CH, FC, dll
                            }
                        }
                    
                    tasks.append(TaskRequest(
                        jobType: job.jobType,
                        area: formattedHoles,
                        priority: priority,
                        description: job.description
                    ))
                }
                
                divisionRequests.append(
                    DivisionRequest(
                        divisionId: division.id,
                        locationId: location.id,
                        tasks: tasks
                    )
                )
            }
        }
        
        return DailyProgramRequest(
            date: formatter.string(from: now),
            divisions: divisionRequests
        )
    }
    
    func addDivision() {
        if let index = cigolfDivision.firstIndex(where: { !$0.isSelected }) {
            cigolfDivision[index].isSelected = true
            addLocation(id: index)
            print("Divisi ditambahkan:", cigolfDivision[index].name)
        } else {
            print("Semua divisi sudah dipilih")
        }
    }
    
    func addJob(divId: Int, locId: Int) {
        cigolfDivision[divId].locations[locId].jobs.append(DailyJob())
    }
    
    func addLocation(id: Int) {
        cigolfDivision[id].locations.append(CigolfLocation(id: cigolfLocation.count + 1))
        cigolfDivision[id].locations[cigolfDivision[id].locations.count - 1].jobs.append(DailyJob())
    }
    
    func isSelectedAllLocation(id: Int) -> Bool {
        return cigolfDivision[id].locations.allSatisfy { $0.isSelected }
    }
    
    
    func isSelectedAllDivision() -> Bool {
        return cigolfDivision.allSatisfy { $0.isSelected }
    }
    
    func createDailyProgram(foremanId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        guard let request = dailyProgramRequest else {
            print("❌ dailyProgramRequest masih nil!")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]

            let response: CreateDailyProgramResponse = try await APIService.shared.post(
                "/foreman/\(foremanId)/daily-task",
                parameters: jsonObject,
                responseType: CreateDailyProgramResponse.self
            )
            print("Daily program created ✅ status:", response.status)
            await MainActor.run {
                self.successMessage = "Program harian berhasil dibuat!"
                self.showSuccessAlert = true
            }
//            self.resetForm()
        } catch {
            print("❌ Failed to create daily program:", error.localizedDescription)
            await MainActor.run {
                self.successMessage = "Gagal membuat program: \(error.localizedDescription)"
                self.showSuccessAlert = true
            }
        }
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
    
//    func exportFile(for foremanId: Int, dailyIds: [Int]) async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        // gabungkan dailyIds jadi query string
////        let query = dailyIds.map { String($0) }.joined(separator: ",")
////        print(query)
//        let urlString = "/foreman/\(foremanId)/daily-task/export?type=csv&daily_ids=\(dailyIds)"
//        
//        do {
//            // Ambil raw data (ZIP)
//            let data: Data = try await APIService.shared.requestRaw(
//                urlString,
//                method: .get
//            )
//            
//            // Simpan ke temporary file
//            let filename = "DailyReport.zip"
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
//            try data.write(to: tempURL)
//            
//            // Buka share sheet biar bisa "Save to Files" atau AirDrop
//            DispatchQueue.main.async {
//                let av = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
//                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let root = scene.windows.first?.rootViewController {
//                    root.present(av, animated: true)
//                }
//            }
//            
//        } catch {
//            print("Export ZIP error:", error.localizedDescription)
//            self.errorMessage = "Failed to export ZIP: \(error.localizedDescription)"
//        }
//    }
    
//    func exportFile(for foremanId: Int, dailyIds: [Int]) async {
//        do {
//            // Buat string JSON mentah "[42,43,47]"
//            let dailyIdsString = "[\(dailyIds.map { String($0) }.joined(separator: ","))]"
//            
//            // Rakitan URL manual tanpa encoding
//            let path = "/foreman/\(foremanId)/daily-task/export?type=csv&daily_ids=\(dailyIdsString)"
//            print("Export Path:", path) // Harus persis: ...?daily_ids=[42,43,47]
//            
//            // Gunakan APIService.shared
//            let data = try await APIService.shared.requestRaw(path, method: "GET")
//            
//            // Simpan ke temporary file
//            let filename = "DailyReport.zip"
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
//            try data.write(to: tempURL)
//            
//            // Tampilkan share sheet
//            DispatchQueue.main.async {
//                let av = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
//                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let root = scene.windows.first?.rootViewController {
//                    root.present(av, animated: true)
//                }
//            }
//            
//        } catch {
//            print("Export ZIP error:", error.localizedDescription)
//        }
//    }

    
    func fetchReportDetail(for foremanId: Int, reportId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: DashboardResponse = try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task/\(reportId)",
                responseType: DashboardResponse.self
            )
            self.reportDetail = response.data
        } catch {
            self.errorMessage = "Failed to load report: \(error.localizedDescription)"
        }
    }
}
