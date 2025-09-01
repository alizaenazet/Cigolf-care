//
//  WeeklyPlan.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 01/09/25.
//

import Foundation

struct WeeklyPlanPreviewResponse: Codable {
    var status: String
    var message: String
    var data: [WeeklyPlanPreview]
}

struct WeeklyPlanPreview: Identifiable, Codable {
    let id: Int
    let startAt: String
    let endAt: String
    
    var startDate: Date? {
        return startAt.toDate()
    }
    
    var endDate: Date? {
        return endAt.toDate()
    }
}

