//
//  PackyButton.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

struct PackyButton: View {

    enum SizeType {
        case large
        case medium
        case small
    }

    enum ColorType {
        case purple
        case black
        case lightPurple
    }

    let title: String
    
    var sizeType: SizeType = .large
    var colorType: ColorType = .purple

    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(
                PackyButtonStyle(
                    sizeType: sizeType,
                    colorType: colorType
                )
            )
    }
}

// MARK: - Button Style

struct PackyButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var sizeType: PackyButton.SizeType = .large
    var colorType: PackyButton.ColorType = .purple

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .packyFont(packyFont)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor(isPressed: isPressed))
            }

    }
}

// MARK: - Inner Properties

private extension PackyButtonStyle {
    var textColor: Color {
        guard isEnabled else { return .white }
        return colorType == .lightPurple ? .purple600 : .white
    }

    func backgroundColor(isPressed: Bool) -> Color {
        guard isEnabled else { return .gray300 }
        switch colorType {
        case .purple:       return isPressed ? .purple600 : .purple500
        case .black:        return isPressed ? .gray800 : .black
        case .lightPurple:  return isPressed ? .purple100 : .purple200
        }
    }

    var height: CGFloat {
        switch sizeType {
        case .large:    return 58
        case .medium:   return 50
        case .small:    return 36
        }
    }

    var cornerRadius: CGFloat {
        switch sizeType {
        case .large:    return 16
        case .medium:   return 8
        case .small:    return 8
        }
    }

    var packyFont: PackyFont {
        switch sizeType {
        case .large:    return .body2
        case .medium:   return .body4
        case .small:    return .body6
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            Text("Large").packyFont(.body1)
            PackyButton(title: "Confirm") {}
            PackyButton(title: "Confirm", colorType: .black) {}
            PackyButton(title: "Confirm", colorType: .lightPurple) {}
            PackyButton(title: "Confirm", colorType: .lightPurple) {}
                .disabled(true)

            Text("Medium").packyFont(.body1)
                .padding(.top)
            PackyButton(title: "Confirm", sizeType: .medium) {}
            PackyButton(title: "Confirm", sizeType: .medium, colorType: .black) {}
            PackyButton(title: "Confirm", sizeType: .medium, colorType: .lightPurple) {}
            PackyButton(title: "Confirm", sizeType: .medium, colorType: .lightPurple) {}
                .disabled(true)

            Text("Small").packyFont(.body1)
                .padding(.top)
            PackyButton(title: "Confirm", sizeType: .small) {}
            PackyButton(title: "Confirm", sizeType: .small, colorType: .black) {}
            PackyButton(title: "Confirm", sizeType: .small, colorType: .lightPurple) {}
            PackyButton(title: "Confirm", sizeType: .small, colorType: .lightPurple) {}
                .disabled(true)
        }
        .padding(.horizontal)
    }
}
