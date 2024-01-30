//
//  BoxDetailView.swift
//  Packy
//
//  Created Mason Kim on 1/29/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import YouTubePlayerKit

// MARK: - View

struct BoxDetailView: View {
    private let store: StoreOf<BoxDetailFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxDetailFeature>
    @ObservedObject private var player: YouTubePlayer = .init()

    init(store: StoreOf<BoxDetailFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.player = .init(stringLiteral: viewStore.youtubeUrl)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { proxy in
                ScrollView {
                    ZStack {
                        // blur 가 가장자리를 하얗게 만들기 때문에 뒤에 black을 깔아줌
                        Color.gray900.ignoresSafeArea()

                        overlayPresentingViews

                        mainContentView
                            .frame(height: proxy.size.height)

                        ZStack {

                            // TODO: 박스 디자인 띄우기
                            // viewStore.boxId
                            // if let selectedBox = viewStore.selectedBox {
                            //     KFImage(URL(string: viewStore.boxId))
                            //         .zIndex(1)
                            //         .ignoresSafeArea()
                            //         .transition(.move(edge: .top))
                            // }

                        }
                    }
                }
            }

            navigationBar
                .zIndex(2)
        }
        .background(.gray900)
        .blur(radius: viewStore.presentingState != .detail ? 3 : 0)
        .animation(.easeInOut, value: viewStore.presentingState)
        .onAppear {
            // player.play()
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxDetailView {
    @ViewBuilder
    var overlayPresentingViews: some View {
        Color.black
            .opacity(viewStore.presentingState == .detail ? 0 : 0.6)
            .ignoresSafeArea()
            .zIndex(10)
            .onTapGesture {
                viewStore.send(.binding(.set(\.$presentingState, .detail)))
            }

        BoxDetailPhotoView(
            imageUrl: "https://picsum.photos/id/237/200/300",
            text: "기억나니 우리의 추억"
        )
        .opacity(viewStore.presentingState == .photo ? 1 : 0)
        .transition(.push(from: .top))
        .zIndex(10)

        BoxDetailLetterView(
            text: viewStore.letterContent,
            borderColor: .pink300
        )
        .padding(.horizontal, 24)
        .opacity(viewStore.presentingState == .letter ? 1 : 0)
        .transition(.push(from: .top))
        .zIndex(10)
    }

    var mainContentView: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            VStack(spacing: 0) {
                ZStack {
                    Text("From. \(viewStore.senderName)")
                        .packyFont(.body2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 72)

                    Rectangle()
                        .fill(.clear)
                        .frame(height: 48)
                }

                HStack {
                    // 추억 사진
                    PhotoElementView(
                        photoUrl: "https://picsum.photos/id/237/200/300",
                        screenWidth: screenWidth
                    ) {
                        viewStore.send(.binding(.set(\.$presentingState, .photo)))
                    }

                    Spacer()

                    // 스티커1
                    StickerElementView(
                        stickerType: .sticker1,
                        stickerURL: "https://picsum.photos/100", // TODO: API 응답 viewStore.stickers.first.imageUrl
                        screenWidth: screenWidth
                    )
                    .disabled(true)
                    .offset(y: 10)
                }
                .padding(.leading, 33)
                .padding(.trailing, 36)
                .padding(.top, 36)

                HStack {
                    // 스티커2
                    StickerElementView(
                        stickerType: .sticker2,
                        stickerURL: "https://picsum.photos/150", // TODO: API 응답 viewStore.stickers.last.imageUrl
                        screenWidth: screenWidth
                    )
                    .disabled(true)

                    Spacer()

                    // 편지
                    LetterElementView(
                        input: .init(selectedLetterDesign: nil, letter: viewStore.letterContent),
                        screenWidth: screenWidth
                    ) {
                        viewStore.send(.binding(.set(\.$presentingState, .letter)))
                    }
                }
                .padding(.leading, 36)
                .padding(.trailing, 33)
                .padding(.top, 36)

                // 음악
                MusicElementView(
                    player: player,
                    screenWidth: screenWidth
                )
                .padding(.horizontal, 32)
                .padding(.top, 43)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Button {

                } label: {
                    VStack(spacing: 0) {
                        Image(.arrowUp)
                            .renderingMode(.template)
                            .foregroundStyle(.white)

                        Text("밀어서 선물 확인하기")
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    var navigationBar: some View {
        FloatingNavigationBar(
            leadingAction: {

            },
            trailingType: .close,
            trailingAction: {

            }
        )
    }
}

// MARK: - Preview

#Preview {
    BoxDetailView(
        store: .init(
            initialState: .init(),
            reducer: {
                BoxDetailFeature()
                    ._printChanges()
            }
        )
    )
}
