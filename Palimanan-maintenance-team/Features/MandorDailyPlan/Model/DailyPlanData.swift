//
//  DailyPlanData.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

struct DailyPlanData: Decodable, Identifiable {
    let id: Int
    let createdAt: String
    let approved: ApprovedStatus
    let outsourceCompany: String
    let foremanName: String
    let totalTasks: Int
    let finishedTasks: Int
    let pendingTasks: Int
    let divisions: [DivisionMandorDaily]
    
    enum CodingKeys: String, CodingKey {
        case id, createdAt, approved, outsourceCompany, foremanName
        case totalTasks = "TotalTasks"
        case finishedTasks, pendingTasks, divisions
    }
}
