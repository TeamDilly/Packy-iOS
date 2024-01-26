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
}

// MARK: - Button Style

struct TextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .packyFont(.body2)
            .foregroundColor(textColor(isPressed: isPressed))
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}

// MARK: - Inner Properties

private extension TextButtonStyle {
    func textColor(isPressed: Bool) -> Color {
        guard isEnabled else { return .gray400 }
        return isPressed ? .gray600 : .gray900
    }
}
