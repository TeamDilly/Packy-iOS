//
//  Font+Packy.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

extension View {
    func packyFont(_ packyFont: PackyFont) -> some View {
        modifier(PackyFontViewModifier(packyFont: packyFont))
    }
}

private struct PackyFontViewModifier: ViewModifier {
    let packyFont: PackyFont

    func body(content: Content) -> some View {
        let uiFont = UIFont(
            name: packyFont.pretendard.rawValue,
            size: packyFont.size
        ) ?? UIFont.systemFont(ofSize: packyFont.size)
        let lineSpacing = packyFont.lineHeight - uiFont.lineHeight

        content
            .font(.pretendard(packyFont.pretendard, size: packyFont.size))
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
}

extension Font {
    static func packy(_ packyFont: PackyFont, size: CGFloat? = nil) -> Font {
        return .custom(packyFont.pretendard.rawValue, size: size ?? packyFont.size)
    }
}
