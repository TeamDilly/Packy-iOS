//
//  TextButtonStyle.swift
//  Packy
//
//  Created by Mason Kim on 1/24/24.
//

import SwiftUI

extension ButtonStyle where Self == TextButtonStyle {
    static var text: TextButtonStyle {
        TextButtonStyle()
    }

    static var textWhite: TextButtonStyle {
        TextButtonStyle(colorType: .white)
    }
}

// MARK: - Button Style

struct TextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var colorType: ColorType = .black

    enum ColorType {
        case black
        case gray
        case white
    }

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .packyFont(.body2)
            .foregroundColor(textColor(isPressed: isPressed))
    }
}

// MARK: - Inner Properties

private extension TextButtonStyle {
    func textColor(isPressed: Bool) -> Color {
        guard isEnabled else { return .gray400 }
        switch colorType {
        case .black:
            return isPressed ? .gray600 : .gray900
        case .gray:
            return isPressed ? .gray300 : .gray600
        case .white:
            return isPressed ? .gray300 : .white
        }

    }
}
