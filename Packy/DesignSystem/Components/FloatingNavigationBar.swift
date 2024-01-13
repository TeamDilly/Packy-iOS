//
//  FloatingNavigationBar.swift
//  Packy
//
//  Created by Mason Kim on 1/14/24.
//

import SwiftUI
import Dependencies

struct FloatingNavigationBar: View {
    @Dependency(\.dismiss) var dismiss

    var leadingIcon: Image = Image(.arrowLeft)
    var leadingAction: (() -> Void)? = nil
    var trailingTitle: String = "다음"
    let trailingAction: () -> Void

    var body: some View {
        HStack {
            Button {
                leadingAction?()
                Task {
                    await dismiss()
                }
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
            } label: {
                Capsule()
                    .fill(.white)
                    .frame(width: 60, height: 40)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .overlay {
                        Text(trailingTitle)
                            .packyFont(.body2)
                            .foregroundStyle(.gray900)
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

#Preview {
    FloatingNavigationBar {
        print("Go!")
    }
}
