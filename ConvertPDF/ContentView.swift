//
//  ContentView.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.router) private var router
    
    @AppStorage("onboardingWasPresented")
    private var onboardingWasPresented = false
    
    @State private var didStartFetching: Bool = false
    @State private var isSplashShownRequiredDuration: Bool = false
    
    @State private var showHomeView: Bool = false
    
    var body: some View {
        ZStack {
            if showHomeView {
                DocumentListScreen()
            } else {
                MainLoader()
            }
        }
        .onAppear {
            guard !didStartFetching else { return }
            didStartFetching = true
            Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                await MainActor.run {
                    isSplashShownRequiredDuration = true
                }
            }
        }
        .onChangeOf(isSplashShownRequiredDuration) { newValue in
            if newValue {
                openApp()
            }
        }
    }
    
    private func openApp() {
        if !onboardingWasPresented {
            router.present_r(OnboardingContent(), style: .fullScreen) {
                showHomeView = true
            }
        } else {
            withAnimation {
                showHomeView = true
            }
        }
    }
}


#Preview {
    ContentView()
}
