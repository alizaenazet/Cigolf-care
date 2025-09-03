//
//  MandorDashboardViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation
import Alamofire

@MainActor
class MandorDashboardViewModel: ObservableObject {
    
    @Published var dailyPlan: DailyPlanData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let allDivisions = ["Operasional", "Landscape", "Projek", "Irigasi", "Mekanik"]
    @Published var selectedDivisionName: String = "Operasional"
    
    init() { }
    
    init(mockPlan: DailyPlanData) {
        self.dailyPlan = mockPlan
    }
    
    func fetchLatestDailyPlan() async {
        guard let foremanId = SessionManager.shared.foremanId else {
            self.errorMessage = "Error: Foreman ID not found for this user. Please log in again."
            return
        }
        
        isLoading = true
        self.errorMessage = nil
        
        do {
            let response: APIResponse<DailyPlanData> = try await APIService.shared.request(
                "/foreman/\(foremanId)/daily-task/latest-day",
                responseType: APIResponse<DailyPlanData>.self
            )
            
            if let data = response.data {
                self.dailyPlan = data
            } else {
                self.errorMessage = response.message
            }
            
        } catch {
            self.errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    var mandorArea: String {
        guard let name = dailyPlan?.foremanName else { return "Unknown Area" }
        switch name {
        case "Darlene McLaughlin": return "Lembah"
        case "Kelly Stanton-Rowe IV": return "Bukit"
        case "Joyce Rutherford": return "Danau"
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
        
        if let selectedDivision = plan.divisions.first(where: { $0.name == selectedDivisionName }) {
            return selectedDivision.locations
        }
        
        return []
    }
    
    var formattedDate: String {
        guard let dateString = dailyPlan?.createdAt else { return "Tanggal tidak tersedia" }
        
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
}
