//
//  Color + ext.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

extension Color {
    static let appBlue = Color(hex: "276DDD")
    static let appMilkBlue = Color(hex: "7CA8F1")
    
    static let appGreen = Color(hex: "76C88B")
    static let appRed = Color(hex: "D44C23")
    
    static let appBlack = Color(hex: "252A2F")
    static let appGray = Color(hex: "A4A8AA")
    static let appBoldGray = Color(hex: "999999")
    static let appStroke = Color(hex: "E1EAF5")
    static let appBackground = Color(hex: "F7F8FE")
    static let appLightBlue = Color(hex: "D0DEF5")
    static let appGrayC1 = Color(hex: "C1C1C1")
    static let appOffWhite = Color(hex: "FCFCFC")
    
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var cleanedHex = hexString

        if cleanedHex.hasPrefix("#") {
            cleanedHex.remove(at: cleanedHex.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)

        if cleanedHex.count == 6 {
            let red = Double((rgb & 0xFF0000) >> 16) / 255.0
            let green = Double((rgb & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgb & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue)
        } else {
            self = .black
        }
    }
}
