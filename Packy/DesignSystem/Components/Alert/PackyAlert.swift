//
//  PackyAlert.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI

// MARK: - View Extension

extension View {
    /// 글로벌하게 사용하기 위한 Alert 설정 - App 단에서 1번만 등록하면 됨
    func packyGlobalAlert() -> some View {
        modifier(PackyAlertPresentationWindowContext())
    }
}

private struct PackyAlertPresentationWindowContext: ViewModifier {
    @State private var alertWindow: UIWindow?

    func body(content: Content) -> some View {
        content.onAppear {
            guard alertWindow == nil else { return }
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.windows.contains(where: \.isKeyWindow) }
            guard let windowScene else { return assertionFailure("Could not get a UIWindowScene") }

            let alertWindow = PassThroughWindow(windowScene: windowScene)
            let alertViewController = UIHostingController(
                rootView: PackyAlertRootView()
            )
            alertViewController.view.backgroundColor = .clear
            alertWindow.rootViewController = alertViewController
            alertWindow.isHidden = false
            alertWindow.windowLevel = .alert
            self.alertWindow = alertWindow
        }
    }
}

// MARK: - Root View

private struct PackyAlertRootView: View {
    @ObservedObject var manager = PackyAlertManager.shared

    var body: some View {
        ZStack {
            if manager.isPresented {
                Color.black
                    .opacity(0.6)
                    .ignoresSafeArea()
            }

            PackyAlert(
                title: manager.configuration.title,
                description: manager.configuration.description,
                cancel: manager.configuration.cancel,
                confirm: manager.configuration.confirm,
                cancelAction: {
                    if manager.configuration.isDismissible {
                        manager.dismiss()
                    }
                    await manager.configuration.cancelAction?()
                }, confirmAction: {
                    if manager.configuration.isDismissible {
                        manager.dismiss()
                    }
                    await manager.configuration.confirmAction()
                }
            )
            .opacity(manager.isPresented ? 1 : 0)
            .zIndex(1)
        }
        .animation(.spring, value: manager.isPresented)
    }
}

// MARK: - View

struct PackyAlert: View {
    var title: String
    var description: String?
    var cancel: String?
    var confirm: String
    var cancelAction: (() async -> Void)?
    var confirmAction: (() async -> Void)

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
                Button {
                    Task { @MainActor in
                        await confirmAction()
                    }
                } label: {
                    Text(confirm)
                        .packyFont(.body2)
                        .foregroundStyle(.gray700)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .contentShape(Rectangle())
                }

                if let cancel {
                    Rectangle()
                        .fill(Color(hex: 0xDDDDDD))
                        .frame(width: 1)

                    Button {
                        Task { @MainActor in
                            await cancelAction?()
                        }
                    } label: {
                        Text(cancel)
                            .packyFont(.body2)
                            .foregroundStyle(.gray900)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentShape(Rectangle())
                    }
                }
            }
            .frame(height: 56)
        }
        .frame(width: 294)
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
                Task {
                    await PackyAlertManager.shared.show(
                        configuration: .init(
                            title: "hello",
                            // description: "hi",
                            cancel: "cancel",
                            confirm: "confirm",
                            cancelAction: {

                            },
                            confirmAction: {

                            }
                        )
                    )

                    print("finish?")
                }
            }
            .packyGlobalAlert()
        }
    }

    return SampleView()
}
