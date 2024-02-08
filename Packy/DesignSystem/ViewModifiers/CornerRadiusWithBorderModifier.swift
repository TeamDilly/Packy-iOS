//
//  CornerRadiusWithBorderModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI

extension View {
    func cornerRadiusWithBorder(radius: CGFloat, backgroundColor: Color? = nil, borderColor: Color, lineWidth: CGFloat) -> some View {
        modifier(
            CornerRadiusWithBorderModifier(cornerRadius: radius, backgroundColor: backgroundColor, borderColor: borderColor, lineWidth: lineWidth)
        )
    }
}

struct CornerRadiusWithBorderModifier: ViewModifier {
    var cornerRadius: CGFloat
    var backgroundColor: Color?
    var borderColor: Color
    var lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor ?? .clear)
                    .strokeBorder(borderColor, lineWidth: lineWidth)
            )
    }
}

