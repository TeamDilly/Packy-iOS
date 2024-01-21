//
//  PackyAlert.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI

// MARK: - View Extension

extension View {
    func packyAlert(
        isPresented: Binding<Bool>,
        title: String,
        description: String? = nil,
        cancel: String? = nil,
        confirm: String,
        cancelAction: (() -> Void)? = nil,
        confirmAction: @escaping (() -> Void)
    ) -> some View {
        modifier(PackyAlertModifier(isPresented: isPresented, title: title, description: description, cancel: cancel, confirm: confirm, cancelAction: cancelAction, confirmAction: confirmAction))
    }
}

// MARK: - View Modifier

struct PackyAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    var title: String
    var description: String?
    var cancel: String?
    var confirm: String
    var cancelAction: (() -> Void)?
    var confirmAction: (() -> Void)

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black
                    .opacity(0.6)
                    .ignoresSafeArea()
            }

            PackyAlert(
                title: title,
                description: description,
                cancel: cancel,
                confirm: confirm,
                cancelAction: {
                    cancelAction?()
                    isPresented = false
                }, confirmAction: {
                    confirmAction()
                    isPresented = false
                }
            )
            .opacity(isPresented ? 1 : 0)
        }
        .animation(.spring, value: isPresented)
    }
}

// MARK: - View

struct PackyAlert: View {
    var title: String
    var description: String?
    var cancel: String?
    var confirm: String
    var cancelAction: (() -> Void)?
    var confirmAction: (() -> Void)

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(title)
                    .packyFont(.heading2)
                    .multilineTextAlignment(.center)

                if let description {
                    Text(description)
                        .packyFont(.body4)
                        .foregroundStyle(.gray700)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 16)

            Rectangle()
                .fill(Color(hex: 0xDDDDDD))
                .frame(height: 1)

            HStack(spacing: 0) {
                if let cancel {
                    Button {
                        cancelAction?()
                    } label: {
                        Text(cancel)
                            .packyFont(.body2)
                            .foregroundStyle(.gray700)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentShape(Rectangle())
                    }

                    Rectangle()
                        .fill(Color(hex: 0xDDDDDD))
                        .frame(width: 1)
                }

                Button {
                    confirmAction()
                } label: {
                    Text(confirm)
                        .packyFont(.body2)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .contentShape(Rectangle())
                }
            }
            .frame(height: 56)
        }
        .frame(width: 294, height: 170)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    struct SampleView: View {
        @State private var isPresented: Bool = true
        var body: some View {
            Button("SHOW!") {
                isPresented = true
            }
            .packyAlert(
                isPresented: $isPresented,
                title: "선물박스를 완성할까요?",
                description: "완성한 이후에는 수정할 수 없어요",
                cancel: "다시 볼게요",
                confirm: "완성할래요"
            ) {
                print("aa")
            }
        }
    }

    return SampleView()
}
