//
//  OnboardingData.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import Foundation

struct OnboardingData: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let subtitle: String
}

extension OnboardingData {
    static let mockData: [OnboardingData] = [
        OnboardingData(
            image: "doc.text.image",
            title: "Create PDFs Easily",
            subtitle: "Add photos or files and quickly convert them into clean, professional PDF documents."
        ),
        OnboardingData(
            image: "square.stack.3d.down.forward",
            title: "Merge and Edit",
            subtitle: "Combine multiple PDFs, remove pages, and organize your documents effortlessly."
        ),
        OnboardingData(
            image: "square.and.arrow.up",
            title: "Share and Save",
            subtitle: "Send or export your PDF files directly, anytime you need them."
        )
    ]
}
