//
//  Font + ext.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

enum AppFont {
    enum Weight {
        case regular
        case medium
        case bold
        case light
        case semibold
        
        var fontWeight: Font.Weight {
            switch self {
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .bold:
                return .bold
            case .light:
                return .light
            case .semibold:
                return .semibold
            }
        }
    }
}

extension Font {
    static func appFont(_ weight: AppFont.Weight, size: CGFloat) -> Font {
        Font.system(size: size, weight: weight.fontWeight)
    }
}
