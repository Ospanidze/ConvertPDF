//
//  PDFViewerScreen.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import SwiftUI
import PDFKit

struct PDFViewerView: View {
    let fileURL: URL
    var onEmptyDocument: (() -> Void)? = nil

    @Environment(\.router) private var router
    @State private var pdfViewRef: PDFView?
    @State private var showShare = false
    @State private var isLoading = true

    var body: some View {
        ZStack {
            LinearGradient.appGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                PDFViewerHeader(
                    title: fileURL.lastPathComponent,
                    onDelete: deleteCurrentPage,
                    onShare: { router.activity(items: [fileURL]) }
                )
                
                PDFKitView(
                    url: fileURL,
                    pdfViewRef: $pdfViewRef,
                    isLoading: $isLoading,
                    onRequestDeleteAtIndex: { index in
                        deletePage(at: index)
                    }
                )
                .edgesIgnoringSafeArea(.bottom)
            }
            
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
    }

    private func deleteCurrentPage() {
        guard let v = pdfViewRef,
              let doc = v.document,
              let page = v.currentPage else { return }

        let idx = doc.index(for: page)
        guard idx >= 0 && idx < doc.pageCount else { return }

        doc.removePage(at: idx)
        let nextIndex = max(0, min(idx, doc.pageCount - 1))

        Task {
            let ok = await Task.detached(priority: .userInitiated) { doc.write(to: fileURL) }.value
            guard ok else {
                await MainActor.run {
                    router.alert("Error", message: "Failed to save the document after deleting the page.") {
                        Button("OK", role: .cancel) {}
                    }
                }
                return
            }

            await MainActor.run {
                if doc.pageCount == 0 {
                    onEmptyDocument?()
                    router.pop()
                } else if let next = doc.page(at: nextIndex) {
                    v.go(to: next)
                }
            }
        }
    }
    
    private func deletePage(at index: Int) {
        guard let v = pdfViewRef,
              let doc = v.document,
              index >= 0 && index < doc.pageCount else { return }

        doc.removePage(at: index)

        let nextIndex = max(0, min(index, doc.pageCount - 1))

        Task {
            let ok = await Task.detached(priority: .userInitiated) { doc.write(to: fileURL) }.value
            guard ok else {
                await MainActor.run {
                    router.alert("Error", message: "Failed to save the document after deleting the page.") {
                        Button("OK", role: .cancel) {}
                    }
                }
                return
            }

            await MainActor.run {
                if doc.pageCount == 0 {
                    onEmptyDocument?()
                    router.pop()
                } else if let next = doc.page(at: nextIndex) {
                    v.go(to: next)
                }
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var pdfViewRef: PDFView?
    @Binding var isLoading: Bool
    let onRequestDeleteAtIndex: (Int) -> Void

    @Environment(\.router) private var router

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.displayMode = .singlePageContinuous
        v.displayDirection = .vertical
        v.autoScales = true
        DispatchQueue.main.async { pdfViewRef = v }

        let long = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        long.minimumPressDuration = 0.45
        v.addGestureRecognizer(long)

        context.coordinator.pdfView = v

        DispatchQueue.global(qos: .userInitiated).async {
            let doc = PDFDocument(url: url)
            DispatchQueue.main.async {
                v.document = doc
                v.minScaleFactor = v.scaleFactorForSizeToFit
                v.maxScaleFactor = v.minScaleFactor * 4
                isLoading = false
            }
        }
        return v
    }

    func updateUIView(_ v: PDFView, context: Context) {
        if pdfViewRef !== v { DispatchQueue.main.async { pdfViewRef = v } }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(router: router, onRequestDeleteAtIndex: onRequestDeleteAtIndex)
    }

    class Coordinator: NSObject {
        weak var pdfView: PDFView?
        private weak var router: Router?
        let onRequestDeleteAtIndex: (Int) -> Void

        init(router: Router?, onRequestDeleteAtIndex: @escaping (Int) -> Void) {
            self.router = router
            self.onRequestDeleteAtIndex = onRequestDeleteAtIndex
        }

        @objc func handleLongPress(_ gr: UILongPressGestureRecognizer) {
            guard gr.state == .began, let view = gr.view as? PDFView, let doc = view.document else { return }

            let location = gr.location(in: view)

            guard let page = view.page(for: location, nearest: true) else { return }
            let pageIndex = doc.index(for: page)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let router = self.router {
                    router.alert("Delete page?", message: nil) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            self.onRequestDeleteAtIndex(pageIndex)
                        }
                    }
                } else {
                    guard let top = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?.rootViewController else { return }

                    let alert = UIAlertController(title: "Delete page?", message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                        self.onRequestDeleteAtIndex(pageIndex)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                    if let pop = alert.popoverPresentationController {
                        pop.sourceView = view
                        pop.sourceRect = CGRect(x: location.x - 1, y: location.y - 1, width: 2, height: 2)
                    }

                    top.present(alert, animated: true)
                }
            }
        }
    }
}


struct PDFViewerHeader: View {
    var title: String
    var onDelete: () -> Void
    var onShare: () -> Void

    @Environment(\.router) private var router

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { router.pop() }) {
                Image(systemName: "chevron.left")
                    .imageScale(.medium)
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())

            Text(title)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            HStack(spacing: 12) {
                Group {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .imageScale(.medium)
                    }

                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.medium)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay(Divider(), alignment: .bottom)
        .zIndex(1)
    }
}
