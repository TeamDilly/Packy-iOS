//
//  LoadingView.swift
//  Packy
//
//  Created by Mason Kim on 2/9/24.
//

import SwiftUI

extension View {
    /// 글로벌하게 사용하기 위한 Loading 설정 - App 단에서 1번만 등록하면 됨
    func globalLoading() -> some View {
        modifier(LoadingViewModifier())
    }

    func showLoading(_ isLoading: Bool, allowTouch: Bool = true) -> some View {
        LoadingManager.shared.isLoading = isLoading
        LoadingManager.shared.allowTouch = allowTouch
        return self
    }
}

private final class LoadingManager: ObservableObject {
    static let shared = LoadingManager()
    private init() {}

    @Published var isLoading: Bool = false
    @Published var allowTouch: Bool = false
}

private struct LoadingViewModifier: ViewModifier {
    @ObservedObject private var manager = LoadingManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if manager.isLoading {
                Group {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    PackyProgress()
                }
                .allowsHitTesting(!manager.allowTouch)
            }
        }
        .animation(.spring(duration: 0.3), value: manager.isLoading)
    }
}

#Preview {
    struct SampleView: View {
        @State private var isLoading: Bool = false
        var body: some View {
            VStack {
                Rectangle()
                    .fill(.blue)
                Text("hello")

                Button("loading") {
                    isLoading.toggle()
                }
            }
            .globalLoading()
            .showLoading(isLoading, allowTouch: true)
        }
    }

    return SampleView()
}
