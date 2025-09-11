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
    @State private var showPreview = false
    @State private var previewURL: URL?

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            Text(String(format: "%02d", index + 1))
                .padding(.leading)
            Text(task.taskType)
            Text(task.area.joined(separator: ", "))
            Text(task.priority)
            if let url = task.imageUrl, !url.isEmpty {
                Button {
                    FileDownloader.downloadTempFile(from: url) { fileURL in
                        if let fileURL = fileURL {
                            DispatchQueue.main.async {
                                FilePresenter.shared.present(url: fileURL, action: .preview)
                            }
                        }
                    }
                } label: {
                    Label("Klik untuk melihat", systemImage: "")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            } else {
                Button {
                } label: {
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
            Text(task.isFinished ? "Selesai" : "Belum")
                .lineLimit(1)
                .foregroundColor(task.isFinished ? .accentColor : .red)

        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
