//
//  FileDownloader.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//


import Foundation

struct FileDownloader {
    static func downloadTempFile(from urlString: String, completion: @escaping (URL?) -> Void) {
        guard let remoteURL = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.downloadTask(with: remoteURL) { tempURL, response, error in
                guard let tempURL = tempURL, error == nil else {
                    completion(nil)
                    return
                }

                // Try to get suggested filename or fallback
                let fileName = response?.suggestedFilename ?? remoteURL.lastPathComponent
                let ext = (fileName as NSString).pathExtension.isEmpty ? "jpg" : (fileName as NSString).pathExtension

                // Create destination with extension in temp dir
                let destinationURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(ext)

                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    completion(destinationURL)
                } catch {
                    print("❌ File move error:", error.localizedDescription)
                    completion(nil)
                }
            }.resume()
    }
}
