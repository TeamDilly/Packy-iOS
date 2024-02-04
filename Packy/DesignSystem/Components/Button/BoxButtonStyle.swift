//
//  BoxButtonStyle.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import SwiftUI

extension ButtonStyle where Self == BoxButtonStyle {
    static func box(
        color: BoxButtonStyle.ColorType,
        size: BoxButtonStyle.SizeType,
        leadingImage: ImageResource? = nil,
        trailingImage: ImageResource? = nil
    ) -> BoxButtonStyle {
        BoxButtonStyle(colorType: color, sizeType: size, leadingImage: leadingImage, trailingImage: trailingImage)
    }
}

// MARK: - Button Style

struct BoxButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var colorType: ColorType
    var sizeType: SizeType
    var leadingImage: ImageResource?
    var trailingImage: ImageResource?

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

        return HStack(spacing: iconSpacing) {
            if let leadingImage {
                Image(leadingImage)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(textColor)
            }

            configuration.label
                .packyFont(packyFont)
                .foregroundStyle(textColor)

            if let trailingImage {
                Image(trailingImage)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(textColor)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, verticalPadding)
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

    var verticalPadding: CGFloat {
        switch sizeType {
        case .rectLarge:    
            return 16
        case .rectMedium, .roundMedium:
            return 14
        case .rectSmall, .roundSmall:
            return 8
        }
    }

    var iconSpacing: CGFloat {
        switch sizeType {
        case .rectLarge:    
            return 12
        case .rectMedium, .roundMedium:
            return 8
        case .rectSmall, .roundSmall:
            return 4
        }
    }

    var iconSize: CGFloat {
        switch sizeType {
        case .rectLarge:
            return 24
        case .rectMedium, .roundMedium:
            return 16
        case .rectSmall, .roundSmall:
            return 12
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
            .buttonStyle(.box(color: .primary, size: .rectLarge, leadingImage: .plus))

        Button("Button") {}
            .buttonStyle(.box(color: .primary, size: .rectMedium, trailingImage: .pause))

        Button("Button") {}
            .buttonStyle(.box(color: .tertiary, size: .rectSmall))

        Button("Button") {}
            .buttonStyle(.box(color: .primary, size: .roundMedium, leadingImage: .arrowDown))

        Button("Button") {}
            .buttonStyle(.box(color: .secondary, size: .roundSmall, leadingImage: .arrowLeft, trailingImage: .arrowRight))
    }
}
