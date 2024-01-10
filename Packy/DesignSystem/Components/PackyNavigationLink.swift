//
//  PackyNavigationLink.swift
//  Packy
//
//  Created by Mason Kim on 1/9/24.
//

import SwiftUI
import ComposableArchitecture

struct PackyNavigationLink<P>: View {
    var title: String
    var pathState: P

    var sizeType: PackyButton.SizeType = .large
    var colorType: PackyButton.ColorType = .purple
    var additionalTapAction: (() -> Void)?

    var body: some View {
        NavigationLink(title, state: pathState)
            .buttonStyle(
                PackyButtonStyle(sizeType: sizeType, colorType: colorType)
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        HapticManager.shared.fireNotification(.success)
                        additionalTapAction?()
                    }
            )
    }
}
