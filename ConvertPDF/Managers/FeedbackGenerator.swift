//
//  FeedbackGenerator.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 19.10.2025.
//

import UIKit

class FeedbackGenerator {
    private static var generator: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        return g
    }()
    
    static func trigger() {
        generator.impactOccurred()
        generator.prepare()
    }
}
