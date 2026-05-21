//
//  FileAction.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 10/09/25.
//

import QuickLook
import SwiftUI

enum FileAction {
    case preview
    case share
}

final class FilePresenter: NSObject {
    static let shared = FilePresenter()
    private override init() {}

    // Hold onto data sources so they don't deallocate
    private var quickLookDataSources:
        [QLPreviewController: QuickLookDataSource] = [:]

    func present(url: URL, action: FileAction) {
        guard
            let root = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController
        else {
            print("⚠️ No rootViewController found")
            return
        }

        switch action {
        case .preview:
            let preview = QLPreviewController()
            let ds = QuickLookDataSource(url: url)
            preview.dataSource = ds

            // Keep a strong ref until dismissed
            quickLookDataSources[preview] = ds

            preview.delegate = self
            root.present(preview, animated: true)

        case .share:
            let vc = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            if let popover = vc.popoverPresentationController {
                popover.sourceView = root.view
                popover.sourceRect = CGRect(
                    x: root.view.bounds.midX,
                    y: root.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
            root.present(vc, animated: true)
        }
    }

}

// MARK: - Cleanup when dismissed
extension FilePresenter: QLPreviewControllerDelegate {
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        if let ds = quickLookDataSources[controller] {
            // Only clean if the file is in tmp (so we don’t delete user Documents or downloads)
            if ds.url.path.hasPrefix(
                FileManager.default.temporaryDirectory.path
            ) {
                try? FileManager.default.removeItem(at: ds.url)
                print("🗑️ Deleted temp file:", ds.url.lastPathComponent)
            }
        }
        quickLookDataSources[controller] = nil
    }
}

// MARK: - QuickLook DataSource
private class QuickLookDataSource: NSObject, QLPreviewControllerDataSource {
    let url: URL
    init(url: URL) { self.url = url }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        url as NSURL
    }
}
