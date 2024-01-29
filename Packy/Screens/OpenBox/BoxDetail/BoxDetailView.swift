//
//  BoxDetailView.swift
//  Packy
//
//  Created Mason Kim on 1/29/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

// MARK: - View

struct BoxDetailView: View {
    private let store: StoreOf<BoxDetailFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxDetailFeature>

    init(store: StoreOf<BoxDetailFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width

            ZStack(alignment: .topTrailing) {

                // TODO: 박스 디자인 띄우기
                // viewStore.boxId
                // if let selectedBox = viewStore.selectedBox {
                //     KFImage(URL(string: viewStore.boxId))
                //         .zIndex(1)
                //         .ignoresSafeArea()
                //         .transition(.move(edge: .top))
                // }

                FloatingNavigationBar(
                    leadingAction: {

                    },
                    trailingType: .close,
                    trailingAction: {

                    }
                )
                .zIndex(2)
            }

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
                        photoUrl: viewStore.photos.first?.photoUrl ?? "",
                        screenWidth: screenWidth
                    ) {
                        // TODO: 사진 자세히 보기
                    }

                    Spacer()

                    // 스티커1
                    StickerElementView(
                        stickerType: .sticker1,
                        stickerURL: "www.naver.com", // TODO: API 응답 viewStore.stickers.first.imageUrl
                        screenWidth: screenWidth
                    )
                    .offset(y: 10)
                }
                .padding(.leading, 33)
                .padding(.trailing, 36)
                .padding(.top, 36)

                HStack {
                    // 스티커2
                    StickerElementView(
                        stickerType: .sticker2,
                        stickerURL: "www.naver.com", // TODO: API 응답 viewStore.stickers.last.imageUrl
                        screenWidth: screenWidth
                    )

                    Spacer()

                    // 편지 쓰기
                    LetterElementView(
                        input: .init(selectedLetterDesign: nil, letter: viewStore.letterContent),
                        screenWidth: screenWidth
                    ) {
                        // TODO: 편지 탭
                    }
                }
                .padding(.leading, 36)
                .padding(.trailing, 33)
                .padding(.top, 36)

                // 음악 추가하기
                MusicElementView(url: viewStore.youtubeUrl, screenWidth: screenWidth)
                    .padding(.horizontal, 32)
                    .padding(.top, 43)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // TODO: 밀어서 선물 확인하기
                //
            }
        }
        .background(.gray900)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
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
