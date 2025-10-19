//
//  DocumentImportManager.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//


import UniformTypeIdentifiers
import PDFKit
import UIKit

final class DocumentImportManager {
    static let shared = DocumentImportManager()
    private init() {}

    func importFromFiles(urls: [URL], combineImagesIntoSinglePDF: Bool = false) async -> [URL] {
        var pdfURLs: [URL] = []
        var imageURLs: [URL] = []

        for url in urls {
            guard let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType else { continue }
            if type.conforms(to: .pdf) {
                pdfURLs.append(url)
            } else if type.conforms(to: .image) {
                imageURLs.append(url)
            }
        }

        let copiedPDFs: [URL] = await withTaskGroup(of: URL?.self) { group in
            for url in pdfURLs {
                group.addTask { await self.copyPDFToDocumentsUnique(url: url) }
            }
            var result: [URL] = []
            for await out in group { if let out { result.append(out) } }
            return result
        }

        var producedFromImages: [URL] = []

        if !imageURLs.isEmpty {
            if combineImagesIntoSinglePDF {
                if let url = await createPDF(fromImageURLs: imageURLs,
                                             name: defaultName(from: imageURLs.first)) {
                    producedFromImages = [url]
                }
            } else {
                producedFromImages = await withTaskGroup(of: URL?.self) { group in
                    for url in imageURLs {
                        group.addTask {
                            await self.createPDF(fromImageURLs: [url],
                                                 name: self.defaultName(from: url))
                        }
                    }
                    var result: [URL] = []
                    for await out in group { if let out { result.append(out) } }
                    return result
                }
            }
        }

        return copiedPDFs + producedFromImages
    }

  
    private func defaultName(from url: URL?) -> String {
        url?.deletingPathExtension().lastPathComponent ?? "File"
    }

    private func createPDF(fromImageURLs urls: [URL], name: String) async -> URL? {
        await Task.detached(priority: .userInitiated) {
            var images: [UIImage] = []
            images.reserveCapacity(urls.count)

            for u in urls {
                _ = u.startAccessingSecurityScopedResource()
                defer { u.stopAccessingSecurityScopedResource() }

                guard let data = try? Data(contentsOf: u),
                      let img = UIImage(data: data)?.normalizedRGB(maxSide: 3000)
                else { continue }
                images.append(img)
            }

            return PDFGeneratorManager.shared.createPDFFrom(images: images, name: name)
        }.value
    }

    private func copyPDFToDocumentsUnique(url: URL) async -> URL? {
        await Task.detached(priority: .userInitiated) {
            let fm = FileManager.default
            guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

            var dest = docs.appendingPathComponent(url.lastPathComponent)
            var i = 1
            while fm.fileExists(atPath: dest.path) {
                let base = dest.deletingPathExtension().lastPathComponent
                dest = docs.appendingPathComponent("\(base) \(i).pdf")
                i += 1
            }

            do {
                _ = url.startAccessingSecurityScopedResource()
                defer { url.stopAccessingSecurityScopedResource() }
                try fm.copyItem(at: url, to: dest)
                return dest
            } catch {
                print("Copy error:", error)
                return nil
            }
        }.value
    }
}

// MARK: - UIImage helpers
private extension UIImage {
    func normalizedRGB(maxSide: CGFloat) -> UIImage {
        let scale = min(1, maxSide / max(size.width, size.height))
        let target = CGSize(width: size.width * scale, height: size.height * scale)

        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = self.scale
        fmt.opaque = true
        
        return UIGraphicsImageRenderer(size: target, format: fmt).image { _ in
            self.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
