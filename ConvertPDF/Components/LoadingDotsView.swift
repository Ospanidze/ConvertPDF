//
//  LoadingDotsView.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

struct LoadingDotsView: View {
    enum Mode {
        case once
        case loop
    }
    
    @State private var activeIndex = 0
    @State private var isAnimating = true
    
    let totalDuration: Double
    let mode: Mode
    let onFinished: () -> Void
    
    private let selectedColor: Color = .appMilkBlue
    private let unselectedColor: Color = .appLightBlue
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i == activeIndex ? selectedColor : unselectedColor)
                    .frame(height: i == 1 ? 32 : 24)
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        switch mode {
        case .once:
            playOnce()
        case .loop:
            playLoop()
        }
    }
    
    private func stopAnimation() {
        isAnimating = false
    }
    
    private func playOnce() {
        let step = totalDuration / 3
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + step * Double(i)) {
                withAnimation(.easeInOut(duration: step * 0.8)) {
                    activeIndex = i
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            onFinished()
        }
    }
    
    private func playLoop() {
        let step = totalDuration / 3
        isAnimating = true
        
        func cycle(startAt index: Int) {
            guard isAnimating else { return }
            
            withAnimation(.easeInOut(duration: step * 0.8)) {
                activeIndex = index
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + step) {
                cycle(startAt: (index + 1) % 3)
            }
        }
        
        cycle(startAt: 0)
    }
}

#Preview {
    LoadingDotsView(totalDuration: 1.5, mode: .loop, onFinished: {})
}
