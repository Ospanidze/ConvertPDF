//
//  OnboardingScreen.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

struct OnboardingScreen: View {
    
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        ZStack {
            LinearGradient.appGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: vm.currentItem.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .foregroundStyle(Color.accentColor)
                    .padding(.bottom, 12)
                    .transition(.opacity)
                    .id(vm.currentIndex)
                
                Group {
                    Text(vm.currentItem.title)
                        .font(.appFont(.semibold, size: 28))
                        .foregroundStyle(Color.appBlack)
                        .lineLimit(1)
                    
                    Text(vm.currentItem.subtitle)
                        .font(.appFont(.regular, size: 15))
                        .foregroundStyle(Color.appBlack.opacity(0.5))
                    
                }
                .multilineTextAlignment(.center)
                .transition(.scale)
                .id(vm.currentIndex)
                
                Spacer()
                
                PrimaryButton(
                    title: !vm.isLastItem ? "Next" :  "Let's start"
                ) {
                    vm.primaryTapped()
                }
            }
            .padding()
        }
        .animation(.default, value: vm.currentIndex)
    }
}

#Preview {
    OnboardingScreen(vm: .init())
}
