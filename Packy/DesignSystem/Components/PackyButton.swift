//
//  PackyButton.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

struct PackyButton: View {

    let title: String
    let action: () -> Void

    var textColor: Color = .white
    var backgroundColor: Color = .purple500

    var body: some View {
        Button(title, action: action)
            .buttonStyle(
                PackyButtonStyle(
                    textColor: textColor,
                    backgroundColor: backgroundColor
                )
            )
    }
}

private struct PackyButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var textColor: Color
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .packyFont(.body2)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .frame(height: 58)
            }
            .padding(.horizontal, 24)
    }
}
