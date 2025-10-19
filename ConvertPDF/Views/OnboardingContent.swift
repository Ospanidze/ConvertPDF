//
//  OnboardingContent.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

struct OnboardingContent: View {
    @StateObject private var onboardingVM = OnboardingViewModel()
    
    var body: some View {
        Group {
            if onboardingVM.showLoader {
                MainLoader(duration: 2) {
                    print("Loader completed")
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingVM.loaderCompleted()
                    }
                }
            } else if onboardingVM.showPaywall {
                WelcomeScreen()
            } else {
                OnboardingScreen(vm: onboardingVM)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: onboardingVM.showLoader)
        .animation(.default, value: onboardingVM.showPaywall)
    }
}

#Preview {
    OnboardingContent()
}
