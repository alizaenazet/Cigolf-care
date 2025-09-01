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
    var data: [DailyReport]
}

struct DailyReport: Codable, Identifiable {
    var id: Int
    var day: String
    var date: Date
}

struct TableRow: Identifiable {
    let id = UUID()
    let nomor: String
    let hari: String
    let tanggal: String
    var isChecked: Bool = false
}
