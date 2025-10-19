//
//  DocumentListViewModel.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import SwiftUI
import CoreData

@MainActor
final class DocumentListViewModel: ObservableObject {
    @Published var documents: [PDFEntity] = []
    @Published var selection = Set<NSManagedObjectID>()
    @Published var isSelecting = false
    
    var canMerge: Bool { selection.count >= 2 }
    
    private let dataManager = PDFDataManager.shared
    private let pdfManager = PDFGeneratorManager.shared
    
    init() {
        fetchDocuments()
    }
    
    private func fetchDocuments() {
        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PDFEntity.createdAt, ascending: false)]
        
        do {
            documents = try dataManager.context.fetch(request)
        } catch {
            print("Ошибка при загрузке документов: \(error.localizedDescription)")
        }
    }
    
    func toggleSelect(_ doc: PDFEntity) {
        let id = doc.objectID
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }

    func addMockDocument() {
        let newDoc = PDFEntity(context: dataManager.context)
        newDoc.id = UUID()
        newDoc.name = "New document"
        newDoc.createdAt = Date()
        newDoc.filePath = "example.pdf"
        newDoc.thumbnail = nil
        
        dataManager.saveContext()
        fetchDocuments()
    }
    
    func deleteDocumentAndFile(_ doc: PDFEntity) {
        if let name = doc.filePath {
            let url = URL.docsFile(name)
            try? FileManager.default.removeItem(at: url)
        }
        dataManager.context.delete(doc)
        dataManager.saveContext()
        fetchDocuments()
    }
    
    func createPDF(from images: [UIImage]) {
        Task {
            let baseName = "File " + Date().formatted(date: .numeric, time: .shortened)
            guard let url = await pdfManager.createPDFFromAsync(images: images, name: baseName) else {
                print("❌ Не удалось создать PDF")
                return
            }

            await MainActor.run {
                let newDoc = PDFEntity(context: dataManager.context)
                newDoc.id = UUID()
                newDoc.name = url.lastPathComponent
                newDoc.filePath = url.lastPathComponent
                newDoc.createdAt = Date()
                newDoc.thumbnail = pdfManager.thumbnail(for: url)

                dataManager.saveContext()
                fetchDocuments()
            }
        }
    }
    
    func mergeSelected() {
        let picked = documents.filter { selection.contains($0.objectID) }
        guard picked.count >= 2 else { return }

        let urls: [URL] = picked.compactMap {
            guard let name = $0.filePath else { return nil }
            return URL.docsFile(name)
        }

        let name = "Merge " + Date().formatted(date: .numeric, time: .shortened)

        Task {
            let mergedURL = await Task.detached(priority: .userInitiated) { () -> URL? in
                return await self.pdfManager.mergePDFs(urls: urls, outputName: name)
            }.value

            guard let mergedURL = mergedURL else {
                print("❌ не удалось слить PDF")
                return
            }

            await MainActor.run {
                let newDoc = PDFEntity(context: dataManager.context)
                newDoc.id = UUID()
                newDoc.name = mergedURL.lastPathComponent
                newDoc.filePath = mergedURL.lastPathComponent
                newDoc.createdAt = Date()
                newDoc.thumbnail = pdfManager.thumbnail(for: mergedURL)

                dataManager.saveContext()
                fetchDocuments()
                selection.removeAll()
            }
        }
    }
    
    func importFromFiles(urls: [URL]) {
        Task {
            let onlyImages = urls.allSatisfy {
                (try? $0.resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .image)) ?? false
            }
            let shouldCombine = onlyImages && urls.count > 1

            let savedURLs = await DocumentImportManager.shared.importFromFiles(
                urls: urls,
                combineImagesIntoSinglePDF: shouldCombine
            )
            guard !savedURLs.isEmpty else { return }

            let thumbs: [URL: Data?] = await withTaskGroup(of: (URL, Data?).self) { group in
                for url in savedURLs {
                    group.addTask {
                        let data = PDFGeneratorManager.shared.thumbnail(for: url)
                        return (url, data)
                    }
                }
                var dict: [URL: Data?] = [:]
                for await (u, d) in group { dict[u] = d }
                return dict
            }

            await MainActor.run {
                for url in savedURLs {
                    let e = PDFEntity(context: dataManager.context)
                    e.id = UUID()
                    e.name = url.lastPathComponent
                    e.filePath = url.lastPathComponent
                    let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
                    e.createdAt = (attrs?[.creationDate] as? Date)
                               ?? (attrs?[.modificationDate] as? Date)
                               ?? Date()
                    e.thumbnail = thumbs[url] ?? nil
                }
                dataManager.saveContext()
                fetchDocuments()
            }
        }
    }
}


