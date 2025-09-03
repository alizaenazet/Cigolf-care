//
//  DailyPlanData.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

// --- THIS IS THE MAIN FIX ---
// We are adding CodingKeys to ensure the JSON keys map correctly.
struct DailyPlanData: Decodable, Identifiable {
    let id: Int
    let createdAt: String
    let approved: ApprovedStatus
    let outsourceCompany: String
    let foremanName: String
    let totalTasks: Int // Using standard swift camelCase
    let finishedTasks: Int
    let pendingTasks: Int
    let divisions: [DivisionMandorDaily]
    
    // This enum maps the JSON keys to our Swift properties.
    enum CodingKeys: String, CodingKey {
        case id, createdAt, approved, outsourceCompany, foremanName
        case totalTasks = "TotalTasks" // Map "TotalTasks" from JSON to "totalTasks" in Swift
        case finishedTasks, pendingTasks, divisions
    }
}
