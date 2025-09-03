//
//  TaskCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct DailyRepTaskCard: View {
    let task: TaskItem
    let index: Int
    let columns: [GridItem]
    @State private var showPreview = false
    @State private var previewURL: URL?
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            Text(String(format: "%02d", index + 1))
                .padding(.leading)
            Text(task.taskType)
            Text(task.area.joined(separator: ", "))
            Text(task.priority)
            if let url = task.urlPhoto, !url.isEmpty {
                Button {
                    FileDownloader.downloadTempFile(from: url) { fileURL in
                        if let fileURL = fileURL {
                            DispatchQueue.main.async {
                                self.previewURL = fileURL
                                self.showPreview = true
                            }
                        }
                    }
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
        .sheet(isPresented: $showPreview) {
            if let previewURL = previewURL {
                QuickLookPreview(url: previewURL)
            }
        }
    }
}
