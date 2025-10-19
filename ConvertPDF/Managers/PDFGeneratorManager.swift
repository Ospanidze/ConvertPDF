//
//  PDFGeneratorManager.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import PDFKit
import UIKit

final class PDFGeneratorManager {
    static let shared = PDFGeneratorManager()
    private init() {}

    func createPDFFrom(images: [UIImage], name: String) -> URL? {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
       
        var fileURL = docs.appendingPathComponent("\(name).pdf")
        var i = 1
        while FileManager.default.fileExists(atPath: fileURL.path) {
            fileURL = docs.appendingPathComponent("\(name) \(i).pdf")
            i += 1
        }

        let pdf = PDFDocument()
        for (idx, img) in images.enumerated() {
            if let page = PDFPage(image: img) { pdf.insert(page, at: idx) }
        }
        return pdf.write(to: fileURL) ? fileURL : nil
    }
    
    func createPDFFromAsync(images: [UIImage], name: String) async -> URL? {
        await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return nil }
            return self.createPDFFrom(images: images, name: name)
        }.value
    }

    func mergePDFs(urls: [URL], outputName: String) -> URL? {
        guard let fileURL = uniqueURL(forName: "\(outputName).pdf") else { return nil }
        let result = PDFDocument()
        var pageIndex = 0

        for url in urls {
            guard let src = PDFDocument(url: url) else { continue }
            for i in 0..<src.pageCount {
                if let page = src.page(at: i) {
                    result.insert(page, at: pageIndex)
                    pageIndex += 1
                }
            }
        }
        return result.write(to: fileURL) ? fileURL : nil
    }

    func thumbnail(for url: URL, maxSide: CGFloat = 120) -> Data? {
        guard let doc = PDFDocument(url: url), let page = doc.page(at: 0) else { return nil }
        let rect = page.bounds(for: .mediaBox)
        let scale = maxSide / max(rect.width, rect.height)
        let size = CGSize(width: rect.width * scale, height: rect.height * scale)

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let cg = ctx.cgContext
            cg.saveGState()
            cg.translateBy(x: 0, y: size.height)
            cg.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: cg)
            cg.restoreGState()
        }
        return image.jpegData(compressionQuality: 0.7)
    }

    private func uniqueURL(forName name: String) -> URL? {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        var url = docs.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) { return url }

        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension.isEmpty ? "" : "." + url.pathExtension
        var i = 1
        repeat {
            url = docs.appendingPathComponent("\(base) \(i)\(ext)")
            i += 1
        } while FileManager.default.fileExists(atPath: url.path)
        return url
    }
}
