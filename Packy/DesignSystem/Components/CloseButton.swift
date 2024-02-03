//
//  CloseButton.swift
//  Packy
//
//  Created by Mason Kim on 1/8/24.
//

import SwiftUI

struct CloseButton: View {

    enum SizeType {
        case large
        case medium
    }

    enum ColorType {
        case dark
        case light
    }

    var sizeType: SizeType = .large
    var colorType: ColorType = .light

    let action: () -> Void

    var body: some View {
        Button("") {
            action()
        }
        .buttonStyle(
            CloseButtonStyle(
                sizeType: sizeType,
                colorType: colorType
            )
        )
    }
}

// MARK: - Button Style

private struct CloseButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let sizeType: CloseButton.SizeType
    let colorType: CloseButton.ColorType

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .frame(width: height, height: height)
            .background(backgroundColor(isPressed: isPressed))
            .overlay(iconImage)
            .clipShape(Circle())
    }

    private var iconImage: some View {
        Image(.cancel)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: iconHeight, height: iconHeight)
            .foregroundColor(iconColor)
    }
}

// MARK: - Inner Properties

private extension CloseButtonStyle {

    func backgroundColor(isPressed: Bool) -> Color {
        switch colorType {
        case .light:
            return isPressed ? .gray100 : .white
        case .dark:
            guard isEnabled else { return .gray300 }
            return isPressed ? .gray800 : .gray900
        }
    }

    var iconColor: Color {
        switch colorType {
        case .light:    return isEnabled ? .gray900 : .gray300
        case .dark:     return .white
        }
    }

    var height: CGFloat {
        switch sizeType {
        case .large:    return 40
        case .medium:   return 24
        }
    }

    var iconHeight: CGFloat {
        switch sizeType {
        case .large:    return 24
        case .medium:   return 16
        }
    }
}

#Preview {
    VStack {
        Text("Large")
            .packyFont(.body1)

        HStack {
            CloseButton() {}
            CloseButton() {}
                .disabled(true)
                .padding(.trailing)

            CloseButton(colorType: .dark) {}
            CloseButton(colorType: .dark) {}
                .disabled(true)
        }

        Text("Medium")
            .packyFont(.body1)
            .padding(.top)

        HStack {
            CloseButton(sizeType: .medium) {}
            CloseButton(sizeType: .medium) {}
                .disabled(true)
                .padding(.trailing)

            CloseButton(sizeType: .medium, colorType: .dark) {}
            CloseButton(sizeType: .medium, colorType: .dark) {}
                .disabled(true)
        }
    }
    .padding(.horizontal)
}
