//
//  OnboardingViewModel.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {

    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var showPaywall: Bool = false
    @Published private(set) var showLoader: Bool = false

    
    private let data: [OnboardingData] = OnboardingData.mockData
    var currentItem: OnboardingData { data[currentIndex] }
    var isLastItem: Bool { currentIndex == data.count - 1 }

    @AppStorage("onboardingWasPresented")
    private var onboardingWasPresented = false

    func primaryTapped() {
        if isLastItem {
            requestPhotosAndProceed()
        } else {
            currentIndex += 1
        }
    }

    func loaderCompleted() {
        showPaywall = true
        showLoader = false
    }

    
    private func requestPhotosAndProceed() {
        onboardingWasPresented = true
        showLoader = true
    }
}
