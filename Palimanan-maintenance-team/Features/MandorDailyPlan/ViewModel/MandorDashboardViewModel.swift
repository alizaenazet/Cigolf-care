//
//  MandorDashboardViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Alamofire
import Foundation
import UIKit

@MainActor
class MandorDashboardViewModel: ObservableObject {
    
    @Published var dailyPlan: DailyPlanData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let allDivisions = [
        "Operasional", "Landscape", "Projek", "Irigasi", "Mekanik",
    ]
    @Published var selectedDivisionName: String = "Operasional"
    @Published var selectedStatusFilter: TaskStatusFilter = .inProgress
    
    private var foremanId: Int? = nil
    private var timer: Timer?
    private let refetchInterval: TimeInterval = 3.0
    
    init() {}
    
    init(mockPlan: DailyPlanData) {
        self.dailyPlan = mockPlan
    }
    
    enum TaskStatusFilter: String, CaseIterable {
        case inProgress = "Dalam Pengerjaan"
        case finished = "Selesai"
    }
    
    func fetchLatestDailyPlan() async {
        guard let foremanId = SessionManager.shared.foremanId else {
            self.errorMessage = "ID pengguna tidak ditemukan. Silakan login kembali."
            return
        }
        
        isLoading = true
        self.errorMessage = nil
        self.foremanId = foremanId
        
        do {
            let response: APIResponse<DailyPlanData> =
            try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task/latest-day",
                responseType: APIResponse<DailyPlanData>.self
            )
            
            if let data = response.data {
                self.dailyPlan = data
            } else {
                self.errorMessage = "Tidak ada data yang tersedia."
            }
            
        } catch {
            self.errorMessage = "Gagal memuat data. Silakan coba lagi nanti."
        }
        
        isLoading = false
    }
    
    func fetchLatestDailyPlanWithoutLoading() async {
        guard let foremanId = SessionManager.shared.foremanId else {
            self.errorMessage = "ID pengguna tidak ditemukan. Silakan login kembali."
            return
        }
        
        self.errorMessage = nil
        self.foremanId = foremanId  // Store foremanId for refetching
        
        do {
            let response: APIResponse<DailyPlanData> =
            try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task/latest-day",
                responseType: APIResponse<DailyPlanData>.self
            )
            
            if let data = response.data {
                self.dailyPlan = data
            } else {
                self.errorMessage = "Tidak ada data yang tersedia."
            }
            
        } catch {
            self.errorMessage = "Gagal memuat data. Silakan coba lagi nanti."
        }
        
    }
    
    func stopRefetching() {
        timer?.invalidate()
        timer = nil
    }
    
    func startRefetching() {
        stopRefetching()
        self.timer = Timer.scheduledTimer(
            withTimeInterval: refetchInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            Task {
                if await (self.foremanId != nil) {
                    await self.fetchLatestDailyPlanWithoutLoading()
                    print("success refetch mandor daily plan data")
                }
            }
        }
    }
    
    var mandorArea: String {
        guard let name = dailyPlan?.foremanName else { return "Unknown Area" }
        switch name {
        case "Darlene McLaughlin": return "Lembah"
        case "Kelly Stanton-Rowe IV": return "Danau"
        case "Joyce Rutherford": return "Bukit"
        default: return "Area Lain"
        }
    }
    
    var allTaskAreas: String {
        guard let plan = dailyPlan else { return "N/A" }
        let allAreas = plan.divisions
            .flatMap { $0.locations }
            .flatMap { $0.tasks }
            .flatMap { $0.area }
        
        let uniqueAreas = Set(allAreas)
        let sortedAreas = uniqueAreas.sorted()
        return sortedAreas.joined(separator: ", ")
    }
    
    var filteredLocations: [LocationMandorDaily] {
        guard let plan = dailyPlan else { return [] }
        
        guard let selectedDivision = plan.divisions.first(where: {
            $0.name == selectedDivisionName
        }) else {
            return []
        }
        
        let filtered = selectedDivision.locations.compactMap { location -> LocationMandorDaily? in
            let tasks = location.tasks.filter { task in
                switch selectedStatusFilter {
                case .inProgress:
                    return !task.isFinished
                case .finished:
                    return task.isFinished
                }
            }
            
            if tasks.isEmpty {
                return nil
            } else {
                return LocationMandorDaily(locationId: location.locationId, locationName: location.locationName, tasks: tasks)
            }
        }
        
        return filtered
    }
    
    var formattedDate: String {
        guard let dateString = dailyPlan?.createdAt else {
            return "Tanggal tidak tersedia"
        }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "id_ID")
        
        return outputFormatter.string(from: date)
    }
    
    func addSelfNewDailyTask(
        for foremanId: Int,
        taskId: Int,
        divisionId: Int,
        locationId: Int,
        jobType: String,
        area: [String],
        priority: Int,
        description: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: NormalResponse = try await APIService.shared.post(
                "/foreman/\(foremanId)/daily-task/\(taskId)/self-add-new",
                parameters: [
                    "divisionId": divisionId,
                    "locationId": locationId,
                    "jobType": jobType,
                    "area": area,
                    "priority": priority,
                    "description": description,
                    "workerNeeded": nil,
                    "workerAvailable": nil,
                    "workerNameList": nil,
                ],
                responseType: NormalResponse.self
            )
            print("✅ Weekly plan created:", response.message)
        } catch {
            print("❌ Add new daily task failed:", error)
            if let afError = error.asAFError {
                print("🔍 Alamofire error:", afError.errorDescription ?? "")
            }
            self.errorMessage =
            "Gagal dalam membuat jadwal harian. Silahkan coba lagi."
            throw error
        }
    }
    
    func createNewDailyPlanAndTask(
        for foremanId: Int,
        divisionId: Int,
        locationId: Int,
        jobType: String,
        area: [String],
        priority: Int,
        description: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let today = formatter.string(from: Date())
            
            let payload: [String: Any] = [
                "date": today,
                "divisions": [
                    [
                        "divisionId": divisionId,
                        "locationId": locationId,
                        "tasks": [
                            [
                                "jobType": jobType,
                                "area": area,
                                "priority": priority,
                                "description": description,
                            ]
                        ],
                    ]
                ],
            ]
            
            let response: NormalResponse = try await APIService.shared.post(
                "/foreman/\(foremanId)/daily-task/",
                parameters: payload,
                responseType: NormalResponse.self
            )
            
            print("✅ Daily plan created:", response.message)
            
        } catch {
            print("❌ Failed to create daily plan:", error)
            if let afError = error.asAFError {
                print("🔍 Alamofire error:", afError.errorDescription ?? "")
            }
            self.errorMessage =
            "Gagal dalam membuat jadwal harian. Silahkan coba lagi."
            throw error
        }
    }
    
    func updateTask(
        foremanId: Int,
        reportId: Int,
        taskId: Int,
        jobType: String,
        locationId: Int,
        areas: String,
        workerNeeded: Int,
        availableWorker: Int,
        workerNameList: String,
        image: UIImage?,
        description: String?
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        do {
            let endpoint =
            "/foreman/\(foremanId)/daily-task/\(reportId)/update-task/\(taskId)"
            
            let response: NormalResponse = try await APIService.shared
                .putFormData(
                    endpoint,
                    formDataBuilder: { multipart in
                        multipart.append(
                            Data(jobType.utf8),
                            withName: "jobType"
                        )
                        multipart.append(
                            Data("\(locationId)".utf8),
                            withName: "locationId"
                        )
                        
                        multipart.append(
                            Data("\(areas)".utf8),
                            withName: "area"
                        )
                        
                        multipart.append(
                            Data("\(workerNeeded)".utf8),
                            withName: "workerNeeded"
                        )
                        multipart.append(
                            Data("\(availableWorker)".utf8),
                            withName: "availableWorker"
                        )
                        multipart.append(
                            Data("\(workerNameList)".utf8),
                            withName: "workerNameList"
                        )
                        
                        if let data = image?.jpegData(compressionQuality: 0.7) {
                            multipart.append(
                                data,
                                withName: "ImageAttachment",
                                fileName: "task.jpg",
                                mimeType: "image/jpeg"
                            )
                        }
                        
                        multipart.append(
                            Data((description ?? "").utf8),
                            withName: "description"
                        )
                    },
                    responseType: NormalResponse.self
                )
            
            print("✅ Task updated:", response.message)
            await fetchLatestDailyPlan()
            
        } catch {
            print("❌ Update failed:", error)
            throw error
        }
    }
}
