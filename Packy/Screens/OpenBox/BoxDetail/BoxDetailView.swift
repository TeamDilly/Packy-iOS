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

    @Namespace private var mainPage
    @Namespace private var giftPage

    @State private var isOnNextPage: Bool = false
    @State private var scrollProxy: ScrollViewProxy?
    @State private var isBoxPartPresented: Bool = false

    init(store: StoreOf<BoxDetailFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        ZStack {
            // blur 가 가장자리를 하얗게 만들기 때문에 뒤에 black을 깔아줌
            Color.gray900.ignoresSafeArea()

            overlayBackground
                .zIndex(5)

            overlayPresentingViews
                .zIndex(5)

            ZStack(alignment: .topTrailing) {

                if isBoxPartPresented {
                    KFImage(URL(string: viewStore.box.boxTopUrl))
                        .zIndex(1)
                        .ignoresSafeArea()
                        .transition(.move(edge: .top))
                        .offset(y: isOnNextPage ? -200 : 0)
                }

                navigationBar
                    .blur(radius: viewStore.presentingState != .detail ? 3 : 0)
                    .zIndex(2)

                GeometryReader { proxy in
                    ScrollViewReader { scrollProxy in
                        ReadableScrollView(isPageStyle: true) {
                            mainPageView(scrollProxy: scrollProxy)
                                .id(mainPage)
                                .frame(height: proxy.size.height)

                            if viewStore.gift != nil {
                                giftPageView
                                    .id(giftPage)
                                    .frame(height: proxy.size.height)
                            }

                        } offsetChanged: { offset in
                            updatePage(byOffset: offset)
                        }
                        .onAppear {
                            self.scrollProxy = scrollProxy
                        }
                    }
                    .blur(radius: viewStore.presentingState != .detail ? 3 : 0)
                }
            }
            .animation(.spring, value: isOnNextPage)
        }
        .navigationBarBackButtonHidden()
        .background(.gray900)
        .animation(.easeInOut, value: viewStore.presentingState)
        .onAppear {
            withAnimation(.spring) {
                isBoxPartPresented = true
            }
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }

    private func updatePage(byOffset offset: CGFloat) {
        let halfScreen = UIScreen.main.bounds.height / 2
        let isOnNext = offset < -halfScreen
        guard isOnNextPage != isOnNext else { return }
        isOnNextPage = isOnNext
    }
}

// MARK: - Inner Views

private extension BoxDetailView {
    var overlayBackground: some View {
        Color.black
            .opacity(viewStore.presentingState == .detail ? 0 : 0.6)
            .ignoresSafeArea()
            .onTapGesture {
                viewStore.send(.binding(.set(\.$presentingState, .detail)))
            }
    }

    @ViewBuilder
    var overlayPresentingViews: some View {
        if let photo = viewStore.photos.first {
            BoxDetailPhotoView(
                imageUrl: photo.photoUrl,
                text: photo.description
            )
            .opacity(viewStore.presentingState == .photo ? 1 : 0)
        }

        BoxDetailLetterView(
            text: viewStore.letterContent,
            borderColor: Color(hexString: viewStore.envelope.borderColorCode)
        )
        .padding(.horizontal, 24)
        .opacity(viewStore.presentingState == .letter ? 1 : 0)
        
        if viewStore.presentingState == .gift {
            ImageViewer {
                NetworkImage(url: viewStore.gift?.url ?? "", contentMode: .fit)
            } dismissedImage: {
                viewStore.send(.binding(.set(\.$presentingState, .detail)))
            }
            .padding(30)
        }
    }

    func mainPageView(scrollProxy: ScrollViewProxy) -> some View {
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
                        photoUrl: viewStore.photos.first?.photoUrl ?? "",
                        screenWidth: screenWidth
                    ) {
                        viewStore.send(.binding(.set(\.$presentingState, .photo)))
                    }

                    Spacer()

                    if let firstSticker = viewStore.stickers.first(where: { $0.location == 0 }) {
                        // 스티커1
                        StickerElementView(
                            stickerType: .sticker1,
                            stickerURL: firstSticker.imgUrl,
                            screenWidth: screenWidth
                        )
                        .disabled(true)
                        .offset(y: 10)
                    }
                }
                .padding(.leading, 33)
                .padding(.trailing, 36)
                .padding(.top, 36)

                HStack {
                    if let secondSticker = viewStore.stickers.first(where: { $0.location == 0 }) {
                        StickerElementView(
                            stickerType: .sticker2,
                            stickerURL: secondSticker.imgUrl,
                            screenWidth: screenWidth
                        )
                        .disabled(true)
                    }

                    Spacer()

                    // 편지
                    LetterElementView(
                        lettetContent: viewStore.letterContent,
                        letterImageUrl: viewStore.envelope.imageUrl,
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
                    youtubeUrl: viewStore.youtubeUrl,
                    screenWidth: screenWidth
                )
                .padding(.horizontal, 32)
                .padding(.top, 43)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                if !isOnNextPage, viewStore.gift != nil {
                    Button {
                        withAnimation(.spring) {
                            scrollProxy.scrollTo(giftPage, anchor: .top)
                        }
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
            .animation(.easeInOut, value: isOnNextPage)
        }
    }

    var giftPageView: some View {
        VStack {
            Image(.giftFrame)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.gray950)
                .scaledToFit()
                .overlay {
                    NetworkImage(url: viewStore.gift?.url ?? "")
                        .aspectRatio(1, contentMode: .fit)
                        .padding(20)
                }
                .padding(35)
                .overlay(alignment: .bottom) {
                    Button{
                        viewStore.send(.binding(.set(\.$presentingState, .gift)))
                    } label: {
                        Text("이미지 전체보기")
                            .packyFont(.body6)
                            .foregroundStyle(.white)
                            .frame(width: 141, height: 34)
                            .background(
                                Capsule()
                                    .fill(.black.opacity(0.3))
                            )
                    }
                    .offset(y: -95)
                }
        }
    }

    var navigationBar: some View {
        FloatingNavigationBar(
            leadingIcon: isOnNextPage ? Image(.arrowDown) : Image(.arrowLeft),
            leadingAction: {
                if isOnNextPage {
                    withAnimation {
                        scrollProxy?.scrollTo(mainPage)
                    }
                } else {
                    viewStore.send(.backButtonTapped)
                }
            },
            trailingType: isOnNextPage ? .none : .close,
            trailingAction: {
                viewStore.send(.closeButtonTapped)
            }
        )
        .animation(.easeInOut, value: isOnNextPage)
    }
}

// MARK: - Preview

#Preview {
    BoxDetailView(
        store: .init(
            initialState: .init(giftBox: .mock),
            reducer: {
                BoxDetailFeature()
                    ._printChanges()
            }
        )
    )
}
