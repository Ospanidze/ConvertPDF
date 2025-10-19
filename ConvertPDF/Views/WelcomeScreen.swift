//
//  WelcomeScreen.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @Environment(\.router) private var router
    
    var body: some View {
        ZStack {
            LinearGradient.appGradient.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "doc.richtext")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
                    .shadow(radius: 5)
                
                Text("PDF Master")
                    .font(.appFont(.semibold, size: 28))
                    .fontWeight(.bold)
                
                Text("Easily create, edit, and organize PDF files from your photos and documents.")
                    .font(.appFont(.regular, size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                PrimaryButton(title: "Start") {
                    router.dismiss_r()
                }
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeScreen()
}
