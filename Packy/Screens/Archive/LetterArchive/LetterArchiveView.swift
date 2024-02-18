//
//  LetterArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct LetterArchiveView: View {
    private let store: StoreOf<LetterArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<LetterArchiveFeature>
    @Environment(\.scenePhase) private var scenePhase

    init(store: StoreOf<LetterArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            StaggeredGrid(columns: 2, data: viewStore.letters.elements) { letter in
                LetterCell(
                    imageUrl: letter.envelope.imageUrl,
                    text: letter.letterContent
                )
                .bouncyTapGesture {
                    viewStore.send(.letterTapped(letter))
                }
                .onAppear {
                    // Pagination
                    guard viewStore.isLastPage == false,
                          let index = viewStore.letters.firstIndex(of: letter) else { return }

                    let isNearEndForNextPageLoad = index == viewStore.letters.endIndex - 3
                    guard isNearEndForNextPageLoad else { return }
                    viewStore.send(._fetchMoreLetters)
                }
            }
            .zigzagPadding(80)
            .innerSpacing(vertical: 32, horizontal: 16)
        }
        .padding(.horizontal, 24)
        .background(.gray100)
        .didLoad {
            await viewStore
                .send(._onTask)
                .finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            viewStore.send(._didActiveScene)
        }
    }
}

// MARK: - Inner Views

private struct LetterCell: View {
    var imageUrl: String
    var text: String

    var body: some View {
        NetworkImage(url: imageUrl, contentMode: .fit)
            .aspectRatio(163 / 132.44, contentMode: .fit)
            .padding(.top, 36)
            .background(
                Text(text)
                    .packyFont(.body6)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
    }
}

// MARK: - Preview

#Preview {
    LetterArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                LetterArchiveFeature()
                    ._printChanges()
            }
        )
    )
}