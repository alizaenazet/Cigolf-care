//
//  DateHelper.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import Foundation

struct DateHelper {
    static func formattedDate(_ dateString: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        if let date = df.date(from: dateString) {
            df.locale = Locale(identifier: "id_ID")
            df.dateFormat = "EEEE, dd MMMM yyyy"
            return df.string(from: date)
        }
        return dateString
    }
    
    static func dayConverter(day: String) -> String {
        let mapping: [String: String] = [
            "monday": "Senin",
            "tuesday": "Selasa",
            "wednesday": "Rabu",
            "thursday": "Kamis",
            "friday": "Jumat",
            "saturday": "Sabtu",
            "sunday": "Minggu"
        ]
        
        return mapping[day.lowercased()] ?? day
    }
    
    static func formatDateToDDMMYYYY(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        df.locale = Locale(identifier: "id_ID")
        return df.string(from: date)
    }
    
    static func formattedDateWithoutDay(dateStr: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        if let date = df.date(from: dateStr) {
            df.locale = Locale(identifier: "id_ID")
            df.dateFormat = "dd MMMM yyyy"
            return df.string(from: date)
        }
        return dateStr
    }
    
}
