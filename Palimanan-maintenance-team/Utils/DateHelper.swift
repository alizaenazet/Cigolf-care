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
}
