//
//  QuickLookPresenter.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 10/09/25.
//

import QuickLook
import UIKit

struct QuickLookPresenter {
    static func present(fileURL: URL) {
        let preview = QLPreviewController()
        let dataSource = PreviewDataSource(fileURL: fileURL)
        preview.dataSource = dataSource
        preview.delegate = dataSource

        // Keep datasource alive (otherwise it gets deallocated)
        objc_setAssociatedObject(
            preview,
            &AssociatedKeys.dataSource,
            dataSource,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({
                ($0 as? UIWindowScene)?.keyWindow?.rootViewController
            })
            .first
        {
            rootVC.present(preview, animated: true)
        }
    }

    private struct AssociatedKeys {
        static var dataSource = "qlPreviewDataSource"
    }

    private class PreviewDataSource: NSObject, QLPreviewControllerDataSource,
        QLPreviewControllerDelegate
    {
        let fileURL: URL
        init(fileURL: URL) {
            self.fileURL = fileURL
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            fileURL as NSURL
        }

        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ Deleted temp file:", fileURL.lastPathComponent)
            } catch {
                print("⚠️ Could not delete file:", error.localizedDescription)
            }
        }
    }
}
