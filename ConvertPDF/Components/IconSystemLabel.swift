//
//  IconSystemLabel.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 19.10.2025.
//

import SwiftUI

struct IconSystemLabel: View {
    
    let title: String
    
    var body: some View {
        Image(systemName: title)
            .frame(width: 36, height: 36)
    }
}

#Preview {
    IconSystemLabel(title: "photo.on.rectangle.angled")
}
