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
    @Environment(\.scenePhase) private var scenePhase

    init(store: StoreOf<LetterArchiveFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            if store.letters.isEmpty && !store.isLoading {
                Text("아직 선물받은 편지가 없어요")
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
            } else {
                StaggeredGrid(columns: 2, data: store.letters.elements) { letter in
                    LetterCell(
                        imageUrl: letter.envelope.imageUrl,
                        text: letter.letterContent
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.fireFeedback(.soft)
                        store.send(.letterTapped(letter))
                    }
                    .onAppear {
                        // Pagination
                        guard store.isLastPage == false,
                              let index = store.letters.firstIndex(of: letter) else { return }

                        let isNearEndForNextPageLoad = index == store.letters.endIndex - 3
                        guard isNearEndForNextPageLoad else { return }
                        store.send(._fetchMoreLetters)
                    }
                }
                .zigzagPadding(80)
                .innerSpacing(vertical: 32, horizontal: 16)
                .transition(.opacity)
                .frame(maxWidth: .infinity)
            }
        }
        .refreshable {
            await store
                .send(.didRefresh)
                .finish()
        }
        .padding(.horizontal, 24)
        .background(.gray100)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            store.send(._didActiveScene)
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
