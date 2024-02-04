//
//  SettingView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SettingView: View {
    private let store: StoreOf<SettingFeature>
    @ObservedObject private var viewStore: ViewStoreOf<SettingFeature>

    init(store: StoreOf<SettingFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, Setting!")
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    SettingView(
        store: .init(
            initialState: .init(),
            reducer: {
                SettingFeature()
                    ._printChanges()
            }
        )
    )
}
