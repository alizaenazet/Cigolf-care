//
//  TaskCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct TaskCard: View {
    let task: TaskItem
    let index: Int
    let columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            Text(String(format: "%02d", index + 1))
                .padding(.leading)
            Text(task.taskType)
            Text(task.area)
            Text(task.priority)
            if let url = task.urlPhoto, !url.isEmpty {
                Button {
                    // TODO: Open Photo
                } label: {
                    Label("Klik untuk melihat", systemImage: "")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            } else {
                Button {} label: {
                    Label("Klik untuk melihat", systemImage: "")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .disabled(true)
            }
            Text(task.description)
                .lineLimit(1)
            Image(systemName: task.isFinished ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(task.isFinished ? .green : .red)
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
