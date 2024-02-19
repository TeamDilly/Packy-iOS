//
//  ArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct ArchiveView: View {
    private let store: StoreOf<ArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<ArchiveFeature>

    @State private var isFullScreenPresented = false

    init(store: StoreOf<ArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.top, 16)

            tabSelector
                .padding(.vertical, 16)

            /// 각각의 뷰를 한 번씩만 띄워놓고 유지할 수 있도록 이렇게 처리함
            ZStack(alignment: .center) {
                PhotoArchiveView(store: store.scope(state: \.photoArchive, action: \.photoArchive))
                    .opacity(viewStore.selectedTab == .photo ? 1 : 0)

                LetterArchiveView(store: store.scope(state: \.letterArchive, action: \.letterArchive))
                    .opacity(viewStore.selectedTab == .letter ? 1 : 0)

                MusicArchiveView(store: store.scope(state: \.musicArchive, action: \.musicArchive))
                    .opacity(viewStore.selectedTab == .music ? 1 : 0)

                GiftArchiveView(store: store.scope(state: \.giftArchive, action: \.giftArchive))
                    .opacity(viewStore.selectedTab == .gift ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .dimmedFullScreenCover(isPresented: photoPresentBinding) {
            photoOverlayView
        }
        .dimmedFullScreenCover(isPresented: letterPresentBinding) {
            letterOverlayView
        }
        .dimmedFullScreenCover(isPresented: musicPresentBinding) {
            musicOverlayView
        }
        .dimmedFullScreenCover(isPresented: giftPresentBinding) {
            giftOverlayView
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.gray100)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}


// MARK: - Inner Views

private extension ArchiveView {
    var navigationBar: some View {
        Text("모아보기")
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 24)
    }

    var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(ArchiveTab.allCases, id: \.self) { tab in
                let isSelected = viewStore.selectedTab == tab
                Text(tab.description)
                    .packyFont(isSelected ? .body3 : .body4)
                    .foregroundStyle(isSelected ? .white : .gray900)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSelected ? .gray900 : .white)
                    )
                    .onTapGesture {
                        viewStore.send(
                            .binding(.set(\.$selectedTab, tab)),
                            animation: .spring
                        )
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    var photoOverlayView: some View {
        if let photo = viewStore.photoArchive.selectedPhoto {
            BoxDetailPhotoView(
                imageUrl: photo.photoUrl,
                text: photo.description
            )
        }
    }

    @ViewBuilder
    var letterOverlayView: some View {
        if let letter = viewStore.letterArchive.selectedLetter {
            BoxDetailLetterView(
                text: letter.letterContent,
                borderColor: Color(hexString: letter.envelope.borderColorCode)
            )
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    var musicOverlayView: some View {
        if let music = viewStore.musicArchive.selectedMusic {
            MusicPlayerView(youtubeUrl: music.youtubeUrl)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    var giftOverlayView: some View {
        if let gift = viewStore.giftArchive.selectedGift {
            ImageViewer {
                NetworkImage(url: gift.gift.url, contentMode: .fit)
            } dismissedImage: {
                giftPresentBinding.wrappedValue = false
            }
            .padding(50)
        }
    }
}

// MARK: - Inner Properties

private extension ArchiveView {
    var photoPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.photoArchive.selectedPhoto != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.binding(.set(\.photoArchive.$selectedPhoto, nil)))
            }
        )
    }

    var letterPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.letterArchive.selectedLetter != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.binding(.set(\.letterArchive.$selectedLetter, nil)))
            }
        )
    }

    var musicPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.musicArchive.selectedMusic != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.binding(.set(\.musicArchive.$selectedMusic, nil)))
            }
        )
    }

    var giftPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.giftArchive.selectedGift != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.binding(.set(\.giftArchive.$selectedGift, nil)))
            }
        )
    }
}

// MARK: - Preview

#Preview {
    ArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                ArchiveFeature()
                    ._printChanges()
            }
        )
    )
}
