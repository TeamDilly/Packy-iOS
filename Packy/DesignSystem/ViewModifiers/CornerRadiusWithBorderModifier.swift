//
//  CornerRadiusWithBorderModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI

extension View {
    func cornerRadiusWithBorder(radius: CGFloat, borderColor: Color, lineWidth: CGFloat) -> some View {
        modifier(
            CornerRadiusWithBorderModifier(cornerRadius: radius, borderColor: borderColor, lineWidth: lineWidth)
        )
    }
}

struct CornerRadiusWithBorderModifier: ViewModifier {
    var cornerRadius: CGFloat
    var borderColor: Color
    var lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.clear)
                    .strokeBorder(borderColor, lineWidth: lineWidth)
            )
    }
}

