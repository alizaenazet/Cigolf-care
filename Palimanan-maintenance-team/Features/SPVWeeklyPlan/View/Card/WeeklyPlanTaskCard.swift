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
            Text(task.taskType)
            Text(task.area.joined(separator: ", "))
            Text(task.day?.toDate()?.getDayOfWeekID() ?? "-")
            Text(task.description)
                .lineLimit(1)
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 30)
        .cornerRadius(8)
    }
}
