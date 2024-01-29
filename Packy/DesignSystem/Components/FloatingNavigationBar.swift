//
//  FloatingNavigationBar.swift
//  Packy
//
//  Created by Mason Kim on 1/14/24.
//

import SwiftUI
import Dependencies

struct FloatingNavigationBar: View {
    enum TrailingButtonType {
        case text(String)
        case close
    }

    var leadingIcon: Image = Image(.arrowLeft)
    var leadingAction: () -> Void
    var trailingType: TrailingButtonType
    let trailingAction: () -> Void
    var trailingDisabled: Bool = false

    var body: some View {
        HStack {
            Button {
                leadingAction()
                HapticManager.shared.fireFeedback(.medium)
            } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .overlay {
                        leadingIcon
                    }
            }

            Spacer()

            Button {
                trailingAction()
                HapticManager.shared.fireFeedback(.medium)
            } label: {
                trailingButton
            }
            .disabled(trailingDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Inner Views

private extension FloatingNavigationBar {
    @ViewBuilder
    var trailingButton: some View {
        switch trailingType {
        case let .text(title):
            Capsule()
                .fill(.white)
                .frame(width: 60, height: 40)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                .overlay {
                    Text(title)
                        .packyFont(.body2)
                        .foregroundStyle(trailingDisabled ? .gray600 : .gray900)
                }

        case .close:
            Circle()
                .fill(.white)
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                .overlay {
                    Image(.xmark)
                }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        FloatingNavigationBar(
            leadingAction: { },
            trailingType: .text("다음")
        ) {
            print("Go!")
        }

        FloatingNavigationBar(
            leadingAction: { },
            trailingType: .close
        ) {
            print("Go!")
        }
    }
}
