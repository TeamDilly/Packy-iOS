//
//  BoxButtonStyle.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import SwiftUI

extension ButtonStyle where Self == BoxButtonStyle {
    static func box() -> BoxButtonStyle {
        BoxButtonStyle()
    }
}

// MARK: - Button Style

struct BoxButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var colorType: ColorType = .primary
    var sizeType: SizeType = .rectLarge
    var imageResource: ImageResource = .plus

    enum ColorType {
        case primary
        case secondary
        case tertiary
    }

    enum SizeType {
        case rectLarge
        case rectMedium
        case rectSmall
        case roundMedium
        case roundSmall
    }

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return HStack(spacing: 12) {
            Image(imageResource)
                .renderingMode(.template)
                .foregroundStyle(textColor)

            configuration.label
                .packyFont(packyFont)
                .foregroundStyle(textColor)
        }
        .padding(.horizontal, 24)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor(isPressed: isPressed))
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}

// MARK: - Inner Properties

private extension BoxButtonStyle {
    var packyFont: PackyFont {
        switch sizeType {
        case .rectLarge:    return .body2
        case .rectMedium:   return .body4
        case .rectSmall:    return .body6
        case .roundMedium:  return .body4
        case .roundSmall:   return .body6
        }
    }

    var cornerRadius: CGFloat {
        switch sizeType {
        case .rectLarge:    return 16
        case .rectMedium:   return 8
        case .rectSmall:    return 8
        case .roundMedium:  return 100
        case .roundSmall:   return 100
        }
    }

    var textColor: Color {
        switch colorType {
        case .primary, .secondary:
            return .white
        case .tertiary:
            guard isEnabled else { return .gray400 }
            return .gray900
        }
    }

    func backgroundColor(isPressed: Bool) -> Color {
        switch colorType {
        case .primary:
            guard isEnabled else { return .gray300 }
            return isPressed ? .purple600 : .purple500

        case .secondary:
            guard isEnabled else { return .gray300 }
            return isPressed ? .gray800 : .gray900

        case .tertiary:
            guard isEnabled else { return .gray100 }
            return isPressed ? .gray300 : .gray100
        }
    }

}

// MARK: - Preview

#Preview {
    VStack {
        Button("Button") {}
            .buttonStyle(.box())
    }
}
