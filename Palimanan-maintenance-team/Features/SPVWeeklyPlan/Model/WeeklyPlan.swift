//
//  WeeklyPlan.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 01/09/25.
//

import Foundation

//Weekly Plan History
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

// Weekly Plan Detail
// MARK: - Weekly Plan Response
struct WeeklyPlanDetailResponse: Codable {
    let status: String
    let message: String
    let data: WeeklyPlanDetail
}

// MARK: - Weekly Plan
struct WeeklyPlanDetail: Codable, Identifiable {
    let id: Int
    let startAt: String
    let endAt: String
    let createAt: String
    let divisions: [WeeklyDetailDivision]
}

// MARK: - Division
struct WeeklyDetailDivision: Codable, Identifiable {
    let id: Int
    let name: String
    let locations: [WeeklyDetailLocation]
}

// MARK: - Location
struct WeeklyDetailLocation: Codable, Identifiable {
    let locationId: Int
    let location: String
    let tasks: [WeeklyDetailTask]

    var id: Int { locationId }
}

// MARK: - Task
struct WeeklyDetailTask: Codable, Identifiable {
    let id: Int
    let taskType: String
    let day: String?            // nullable in JSON
    let description: String
    let area: [String]
}
