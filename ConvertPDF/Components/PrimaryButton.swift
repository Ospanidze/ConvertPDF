//
//  PrimaryButton.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

enum Appearance {
    case color(Color)
    case gradient(LinearGradient)

    var style: AnyShapeStyle {
        switch self {
        case .color(let color):
            return AnyShapeStyle(color)
        case .gradient(let gradient):
            return AnyShapeStyle(gradient)
        }
    }
}

struct PrimaryButton: View {
    
    let title: String
    let titleColor: Color
    let appearance: Appearance
    let isBorder: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    init(title: String,
         titleColor: Color = .white,
         appearance: Appearance = .gradient(.buttonGrayGradient),
         height: CGFloat = 54,
         cornerRadius: CGFloat = 18,
         isBorder: Bool = false,
         action: @escaping () -> Void
    ) {
        self.title = title
        self.titleColor = titleColor
        self.appearance = appearance
        self.height = height
        self.cornerRadius = cornerRadius
        self.isBorder = isBorder
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .frame(height: height)
                .foregroundStyle(appearance.style)
                .overlay {
                    Text(title)
                        .font(.appFont(.medium, size: 16))
                        .lineLimit(1)
                        .foregroundStyle(titleColor)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                }
                .overlay {
                    if isBorder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.appMilkBlue, lineWidth: 1)
                    }
                }
        }
    }
}

#Preview {
    PrimaryButton(title: "dafdaf", action: {})
}
