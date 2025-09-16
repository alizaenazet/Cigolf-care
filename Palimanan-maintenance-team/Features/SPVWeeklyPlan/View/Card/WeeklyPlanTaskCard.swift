//
//  TaskCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct WeeklyPlanTaskCard: View {
    let task: WeeklyDetailTask
    let index: Int
    let columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            Text(String(format: "%02d", index + 1))
                .padding(.leading)
                .lineLimit(nil)  // unlimited lines
                .multilineTextAlignment(.leading)
            Text(task.taskType)
                .lineLimit(nil)  // unlimited lines
                .multilineTextAlignment(.leading)
            Text(task.area.joined(separator: ", "))
                .lineLimit(nil)  // unlimited lines
                .multilineTextAlignment(.center)
            Text(task.day?.toDate()?.getDayOfWeekID() ?? "-")
                .lineLimit(nil)  // unlimited lines
                .multilineTextAlignment(.center)
            Text(task.description)
                .lineLimit(nil)  // unlimited lines
                .multilineTextAlignment(.leading)
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 30)
        .cornerRadius(8)
    }
}
