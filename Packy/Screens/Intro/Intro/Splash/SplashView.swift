//
//  SplashView.swift
//  Packy
//
//  Created Mason Kim on 2/5/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SplashView: View {
    let store: StoreOf<SplashFeature>

    var body: some View {
        VStack {
            Image(.logoLarge)
                .offset(y: -12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.purple500)
    }
}

// MARK: - Preview

#Preview {
    SplashView(
        store: .init(
            initialState: .init(),
            reducer: {
                SplashFeature()
                    ._printChanges()
            }
        )
    )
}
