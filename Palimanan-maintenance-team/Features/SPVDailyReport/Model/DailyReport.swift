//
//  DailyReport.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import Foundation

struct DailyReportResponse: Codable {
    var status: String
    var message: String
    var data: [DailyReport]?
}

struct DailyReport: Codable, Identifiable {
    var id: Int
    var day: String
    var date: String
    var isChecked: Bool = false // ✅ default tidak tercentang
    
    enum CodingKeys: String, CodingKey {
        case id, day, date // hanya ini yang datang dari backend
    }
}

struct CigolfDivision: Identifiable{
    var id: Int
    var name: String
    var isSelected: Bool = false
    var locations: [CigolfLocation] = []
}

struct DailyJob: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var day: String? = nil
    var jobType: String = ""
    var holeArea: String = ""
    var priority: String = ""
    var description: String = ""
}

struct CigolfLocation: Identifiable, Hashable {
    var id: Int
    var name: String = ""
    var isSelected: Bool = false
    var jobs: [DailyJob] = []
}

struct DailyProgramRequest: Codable {
    var date: String
    var divisions: [DivisionRequest]
}

struct DivisionRequest: Codable {
    var divisionId: Int
    var locationId: Int
    var tasks: [TaskRequest]
}

struct TaskRequest: Codable {
    var jobType: String
    var area: [String]
    var priority: Int
    var description: String
}
