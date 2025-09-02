//
//  DashboardResponse.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//


import Foundation

struct DashboardResponse: Codable {
    var status: String
    var message: String
    var data: ForemanReport
}

struct ForemanReport: Codable, Identifiable {
    var id: Int
    var createdAt: String
    var approved: Approval
    var outsourceCompany: String?
    var foremanName: String
    var totalTasks: Int?
    var finishedTasks: Int?
    var pendingTasks: Int?
    var divisions: [Division]

    enum CodingKeys: String, CodingKey {
        case id, createdAt, approved, outsourceCompany, foremanName
        case totalTasks = "TotalTasks"
        case finishedTasks, pendingTasks, divisions
    }
}

struct Approval: Codable {
    var isApproved: Bool
    var approvedAt: String
    var spvName: String
}

struct Division: Codable, Identifiable {
    var id: Int
    var name: String
    var locations: [Location]
}

struct Location: Codable, Identifiable {
    var locationId: Int
    var locationName: String
    var tasks: [TaskItem]

    var id: Int { locationId }
}

struct TaskItem: Codable, Identifiable {
    var id: Int
    var taskType: String
    var description: String
    var priority: String
    var area: [String]
    var needWorker: Int?
    var availableWorker: Int?
    var workerList: [String]?
    var urlPhoto: String?
    var isFinished: Bool
}
