//
//  DocumentListScreen.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import SwiftUI

struct DocumentListScreen: View {
    
    @Environment(\.router) private var router
    
    @StateObject private var viewModel = DocumentListViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.appGradient.ignoresSafeArea()
            
            VStack(spacing: 12) {
                DocumentListHeader(
                    viewModel: viewModel,
                    onAddPhoto: { checkPhotoPermission() },
                    onFiles: {
                        router.present_r(FilePicker { urls in
                            viewModel.importFromFiles(urls: urls)
                        })
                    }
                )
                
                List {
                    ForEach(viewModel.documents, id: \.id) { doc in
                        HStack {
                            if viewModel.isSelecting {
                                let selected = viewModel.selection.contains(doc.objectID)
                                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(Color.accentColor)
                                    .onTapGesture { viewModel.toggleSelect(doc) }
                            }

                            if let path = doc.filePath {
                                if viewModel.isSelecting {
                                    DocumentRowView(doc: doc)
                                        .contentShape(Rectangle())
                                        .onTapGesture { viewModel.toggleSelect(doc)
                                        }
                                } else {
                                    Button(action: {
                                        router.push_r(
                                            PDFViewerView(
                                                fileURL: .docsFile(path),
                                                onEmptyDocument: { viewModel.deleteDocumentAndFile(doc) }
                                            )
                                        )
                                    }) {
                                        DocumentRowView(doc: doc)
                                    }
                                    .contextMenu { rowContextMenu(for: doc) }
                                }
                            } else {
                                DocumentRowView(doc: doc).opacity(0.5)
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    
    private func checkPhotoPermission() {
        let manager = PermissionManager.shared
        let status = manager.checkStatus(for: .photoLibrary)
        
        switch status {
        case .authorized:
            showPicker()
        case .notDetermined:
            manager.requestPermission(for: .photoLibrary) { newStatus in
                if newStatus == .authorized {
                    showPicker()
                } else {
                    showAlert()
                }
            }
            
        case .denied:
            showAlert()
        }
    }
    
    private func showPicker() {
        router.present_r(PhotoPicker { images in
            if !images.isEmpty {
                viewModel.createPDF(from: images)
            }
        })
    }
    
    private func showAlert() {
        router.alert("Access Photos") {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                PermissionManager.shared.openSettings()
            }
        }
    }
    
    @ViewBuilder
    private func rowContextMenu(for doc: PDFEntity) -> some View {
        Button {
            if let fileName = doc.filePath {
                let url = URL.docsFile(fileName)
                router.activity(items: [url])
            }
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }

        Button(role: .destructive) {
            viewModel.deleteDocumentAndFile(doc)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    DocumentListScreen()
}

struct DocumentRowView: View {
    
    let doc: PDFEntity
    
    var body: some View {
        HStack {
            if let data = doc.thumbnail, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
            } else {
                Image(systemName: "doc.text")
                    .resizable()
                    .frame(width: 30, height: 35)
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading) {
                Group {
                    Text(doc.name ?? "")
                        .font(.headline)
                        .foregroundStyle(Color.appBlue)
                    
                    Text((doc.createdAt ?? Date()).formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color.appGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

extension URL {
    static func safeFileURL(_ path: String) -> URL {
        if #available(iOS 16.0, *) {
            return URL(filePath: path)
        } else {
            return URL(fileURLWithPath: path)
        }
    }
    
    static func docsFile(_ fileName: String) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        ?? FileManager.default.temporaryDirectory 
        return docs.appendingPathComponent(fileName)
    }
}


struct DocumentListHeader: View {
    @ObservedObject var viewModel: DocumentListViewModel
    var onAddPhoto: () -> Void
    var onFiles: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("My docs")
                    .font(.title2).bold()
                Text("\(viewModel.documents.count) document\(viewModel.documents.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if viewModel.isSelecting {
                HStack(spacing: 8) {
                    Button(action: {
                        viewModel.mergeSelected()
                        viewModel.isSelecting = false
                    }) {
                        Text("Merge")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 10).padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.12)))
                    }
                    .disabled(!viewModel.canMerge)

                    Button(action: {
                        viewModel.isSelecting = false
                        viewModel.selection.removeAll()
                    }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.secondary.opacity(0.3))
                            )
                    }
                }
            } else {
                HStack(spacing: 10) {
                    Group {
                        Button(action: onAddPhoto) {
                            IconSystemLabel(title: "photo.on.rectangle.angled")
                        }
                        
                        Button(action: onFiles) {
                            IconSystemLabel(title: "folder")
                        }
                        
                        Button(action: { viewModel.isSelecting = true }) {
                            IconSystemLabel(title: "checkmark.circle")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay(Divider().offset(y: 20), alignment: .bottom)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
