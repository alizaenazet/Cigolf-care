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
    var isActive: Bool = false
    var isSelected: Bool = false
}

struct CigolfLocation: Identifiable{
    var id: Int
    var name: String
    var isSelected: Bool = false
}

struct DailyJob: Identifiable {
    let id = UUID()
    var location: CigolfLocation?
    var day: String = ""
    var jobType: String = ""
    var holeArea: String = ""
    var priority: Int = 1
    var notes: String = ""
}
