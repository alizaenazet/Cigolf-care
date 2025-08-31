//
//  DashboardResponse.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//


import Foundation

struct DashboardResponse: Codable {
    let status: String
    let message: String
    let data: ForemanReport
}

struct ForemanReport: Codable, Identifiable {
    let id: Int
    let createdAt: String
    let approved: Approval
    let outsourceCompany: String
    let foremanName: String
    let totalTasks: Int
    let finishedTasks: Int
    let pendingTasks: Int
    let divisions: [Division]

    enum CodingKeys: String, CodingKey {
        case id, createdAt, approved, outsourceCompany, foremanName
        case totalTasks = "TotalTasks"
        case finishedTasks, pendingTasks, divisions
    }
}

struct Approval: Codable {
    let isApproved: Bool
    let approvedAt: String
    let spvName: String
}

struct Division: Codable, Identifiable {
    let id: Int
    let name: String
    let locations: [Location]
}

struct Location: Codable, Identifiable {
    let locationId: Int
    let locationName: String
    let tasks: [TaskItem]

    var id: Int { locationId }
}

struct TaskItem: Codable, Identifiable {
    let id: Int
    let taskType: String
    let description: String
    let priority: String
    let area: String
    let needWorker: Int
    let availableWorker: Int
    let workerList: String
    let isFinished: Bool
}
