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
    
    @State private var isTryToOpen: Bool = false

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            Text(String(format: "%02d", index + 1))
                .padding(.leading)
                .lineLimit(nil)
            Text(task.priority)
                .lineLimit(nil)
            Text(task.taskType)
                .lineLimit(nil)
            Text(task.area.joined(separator: ", "))
                .lineLimit(nil)
            Text(String(task.needWorker ?? 0))
                .lineLimit(nil)
            Text(String(task.availableWorker ?? 0))
                .lineLimit(nil)
            Text(task.workerList?.joined(separator: ", ") ?? "")
                .lineLimit(nil)
            if let url = task.imageUrl, !url.isEmpty {
                Button {
                    isTryToOpen = true
                    FileDownloader.downloadTempFile(from: url) { fileURL in
                        if let fileURL = fileURL {
                            isTryToOpen = false
                            DispatchQueue.main.async {
                                FilePresenter.shared.present(url: fileURL, action: .preview)
                            }
                        }
                    }
                } label: {
                    if isTryToOpen {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: .black
                                )
                            )
                    } else {
                        Label("Klik untuk melihat", systemImage: "")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .lineLimit(nil)
                    }
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
                        .lineLimit(nil)
                }
                .disabled(true)
            }
            Text(task.description)
                .lineLimit(nil)
            Text(task.isFinished ? "Selesai" : "Belum")
                .foregroundColor(task.isFinished ? .accentColor : .red)
                .lineLimit(nil)
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
