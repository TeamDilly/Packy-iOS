//
//  NavigationBar.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI
import Dependencies

struct NavigationBar: View {
    var title: String?
    var leftIcon: Image?
    var leftIconAction: () -> Void = {}
    var rightIcon: Image?
    var rightIconAction: () -> Void = {}
    var dismissible: Bool = true

    @Dependency(\.dismiss) var dismiss

    var body: some View {
        HStack {
            IconView(image: leftIcon) {
                if dismissible {
                    Task {
                        await dismiss()
                    }
                }
                leftIconAction()
            }

            Spacer()

            if let title {
                Text(title)
                    .packyFont(.body1)
                    .foregroundStyle(.gray900)
            }

            Spacer()

            IconView(image: rightIcon, action: rightIconAction)
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
}

// MARK: - Inner Views

private struct IconView: View {
    var image: Image?
    var action: () -> Void

    var body: some View {
        Button {
            action()
            HapticManager.shared.fireFeedback(.medium)
        } label: {
            if let image {
                image
            } else {
                EmptyView()
            }
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Static var

extension NavigationBar {
    static func onlyBackButton(action: (() -> Void)? = nil) -> Self {
        NavigationBar(leftIcon: Image(.arrowLeft), leftIconAction: {
            action?()
        })
    }

    static func backAndCloseButton(
        backButtonAction: (() -> Void)? = nil,
        closeButtonAction: (() -> Void)? = nil
    ) -> Self {
        NavigationBar(
            leftIcon: Image(.arrowLeft),
            leftIconAction: {
                backButtonAction?()
            },
            rightIcon: Image(.xmark),
            rightIconAction: {
                closeButtonAction?()
            }
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        NavigationBar(title: "Title", leftIcon: Image(.arrowLeft), leftIconAction: { print("back") })
            .border(Color.black)

        NavigationBar(leftIcon: Image(.arrowLeft), leftIconAction: { print("back") })
            .border(Color.black)

        NavigationBar(title: "Title", leftIcon: Image(.arrowLeft), leftIconAction: { print("back") }, rightIcon: Image(.person), rightIconAction: { print("person") })
            .border(Color.black)
    }
}
