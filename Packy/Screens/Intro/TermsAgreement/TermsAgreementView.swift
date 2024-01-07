//
//  TermsAgreementView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct TermsAgreementView: View {
    private let store: StoreOf<TermsAgreementFeature>
    @ObservedObject private var viewStore: ViewStoreOf<TermsAgreementFeature>

    init(store: StoreOf<TermsAgreementFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, TermsAgreement!")
        }
        .task {
            await viewStore
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    TermsAgreementView(
        store: .init(
            initialState: .init(),
            reducer: {
                TermsAgreementFeature()
                    ._printChanges()
            }
        )
    )
}
