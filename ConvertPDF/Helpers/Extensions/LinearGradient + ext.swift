//
//  LinearGradient + ext.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

extension LinearGradient {
    static var buttonGrayGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                .appBlue,
                .appMilkBlue
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var appGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "E0EDFF"), location: 0.0),
                .init(color: Color(hex: "FEFEFE"), location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
