//
//  MainLoader.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

struct MainLoader: View {
    
    let mode: LoadingDotsView.Mode
    let duration: Double
    let onFinished: () -> Void
    
    init(duration: Double = 1.5) {
        self.mode = .loop
        self.duration = duration
        self.onFinished = {}
    }
    
    init(duration: Double = 1.5, onFinished: @escaping () -> Void) {
        self.mode = .once
        self.duration = duration
        self.onFinished = onFinished
    }
    
    var body: some View {
        ZStack {
            LinearGradient.appGradient.ignoresSafeArea()
            
            LoadingDotsView(totalDuration: duration, mode: mode, onFinished: mode == .loop ? {} : onFinished)
        }
    }
}

#Preview {
    MainLoader()
}
