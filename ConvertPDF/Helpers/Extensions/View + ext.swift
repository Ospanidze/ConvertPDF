//
//  View + ext.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

extension View {
    
    @inlinable
    @ViewBuilder
    func onChangeOf<V: Equatable>(
        _ value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self.onChange(of: value) { _, newValue in action(newValue) }
        } else {
            self.onChange(of: value) { newValue in action(newValue) }
        }
    }
}
