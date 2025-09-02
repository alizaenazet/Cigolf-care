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

struct TableRow: Identifiable {
    let id = UUID()
    let nomor: String
    let hari: String
    let tanggal: String
    var isChecked: Bool = false
}
