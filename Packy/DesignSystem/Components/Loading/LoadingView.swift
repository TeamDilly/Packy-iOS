//
//  LoadingView.swift
//  Packy
//
//  Created by Mason Kim on 2/9/24.
//

import SwiftUI

extension View {
    func showLoading(_ isLoading: Bool, allowTouch: Bool = true) -> some View {
        modifier(
            LoadingViewModifier(
                isLoading: isLoading,
                allowTouch: allowTouch
            )
        )
    }
}

private struct LoadingViewModifier: ViewModifier {
    var isLoading: Bool
    var allowTouch: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isLoading {
                Group {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    PackyProgress()
                }
                .allowsHitTesting(!allowTouch)
            }
        }
        .animation(.spring(duration: 0.3), value: isLoading)
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
            .showLoading(isLoading, allowTouch: true)
        }
    }

    return SampleView()
}
