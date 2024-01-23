//
//  BoxStartGuideView.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import YouTubePlayerKit

// MARK: - View

struct BoxStartGuideView: View {
    private let store: StoreOf<BoxStartGuideFeature>
    @ObservedObject var viewStore: ViewStoreOf<BoxStartGuideFeature>

    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    init(store: StoreOf<BoxStartGuideFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width

            ZStack {
                if viewStore.isShowingGuideText {
                    guideOverlayView
                }

                VStack(spacing: 0) {
                    FloatingNavigationBar {
                        viewStore.send(.nextButtonTapped)
                    }

                    HStack {
                        // 추억 사진 담기
                        photoView(screenWidth)

                        Spacer()

                        // 스티커1
                        ElementGuideView(element: .sticker1, screenWidth: screenWidth) {
                            viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, true)))
                        }
                        .offset(y: 10)
                    }
                    .padding(.leading, 33)
                    .padding(.trailing, 36)
                    .padding(.top, 36)

                    HStack {
                        // 스티커2
                        ElementGuideView(element: .sticker2, screenWidth: screenWidth) {
                            viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, true)))
                        }
                        .offset(y: -5)

                        Spacer()

                        // 편지 쓰기
                        letterView(screenWidth)
                    }
                    .padding(.leading, 36)
                    .padding(.trailing, 33)
                    .padding(.top, 36)

                    // 음악 추가하기
                    musicView(screenWidth)
                        .padding(.horizontal, 32)
                        .padding(.top, 43)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    bottomButtonsView
                        .padding(.horizontal, 40)
                        .padding(.bottom, 28)
                }
                .background(.gray900)
            }
        }
        // 음악 추가 바텀시트
        .bottomSheet(
            isPresented: viewStore.$isMusicBottomSheetPresented,
            currentDetent: .constant(viewStore.musicInput.musicBottomSheetMode.detent),
            detents: viewStore.musicInput.musicSheetDetents,
            showLeadingButton: viewStore.musicInput.musicBottomSheetMode != .choice,
            leadingButtonAction: { viewStore.send(.musicBottomSheetBackButtonTapped) },
            closeButtonAction: { viewStore.send(.binding(.set(\.$musicInput, .init()))) }
        )  {
            VStack {
                switch viewStore.musicInput.musicBottomSheetMode {
                case .choice:
                    musicAddChoiceBottomSheet
                case .userSelect:
                    musicUserSelectBottomSheet
                case .recommend:
                    musicRecommendationBottomSheet
                }
            }
            .animation(.easeInOut, value: viewStore.musicInput.musicBottomSheetMode.detent)
        }
        // 사진 추가 바텀시트
        .bottomSheet(
            isPresented: viewStore.$isPhotoBottomSheetPresented,
            detents: [.large],
            closeButtonAction: { viewStore.send(.binding(.set(\.$photoInput, .init()))) }
        ) {
            addPhotoBottomSheet
        }
        // 편지 쓰기 바텀시트
        .bottomSheet(
            isPresented: viewStore.$isLetterBottomSheetPresented,
            detents: [.large],
            closeButtonAction: { viewStore.send(.binding(.set(\.$letterInput, .init()))) }
        ) {
            LetterBottomSheet(viewStore: viewStore)
        }
        // 스티커 추가 바텀 시트
        .bottomSheet(
            isPresented: viewStore.$isStickerBottomSheetPresented,
            detents: [.fraction(0.35)],
            isBackgroundBlack: false,
            hideTopButtons: true
        ) {
            addStickerBottomSheet
        }
        .alertButtonTint(color: .black)
        .packyAlert(
            isPresented: viewStore.$isShowBoxFinishAlert,
            title: "선물박스를 완성할까요?",
            description: "완성한 이후에는 수정할 수 없어요",
            cancel: "다시 볼게요",
            confirm: "완성할래요"
        ) {
            viewStore.send(.makeBoxConfirmButtonTapped)
        }
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
        .popGestureDisabled()
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxStartGuideView {
    var guideOverlayView: some View {
        Color.black
            .opacity(0.7)
            .ignoresSafeArea()
            .zIndex(1)
            .overlay {
                Text("빈 공간을 눌러서\n선물박스를 채워보세요")
                    .packyFont(.heading2)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
    }

    @ViewBuilder
    func photoView(_ screenWidth: CGFloat) -> some View {
        if let photoUrl = viewStore.photoInput.photoUrl {
            PhotoPresentingView(
                photoUrl: photoUrl,
                screenWidth: screenWidth
            ) {
                viewStore.send(.binding(.set(\.$isPhotoBottomSheetPresented, true)))
            }
        } else {
            ElementGuideView(element: .photo, screenWidth: screenWidth) {
                viewStore.send(.binding(.set(\.$isPhotoBottomSheetPresented, true)))
            }
        }
    }

    @ViewBuilder
    func letterView(_ screenWidth: CGFloat) -> some View {
        if !viewStore.letterInput.letter.isEmpty {
            LetterPresentingView(
                input: viewStore.letterInput,
                screenWidth: screenWidth
            ) {
                viewStore.send(.binding(.set(\.$isLetterBottomSheetPresented, true)))
            }
        } else {
            ElementGuideView(element: .letter, screenWidth: screenWidth) {
                viewStore.send(.binding(.set(\.$isLetterBottomSheetPresented, true)))
            }
        }
    }

    @ViewBuilder
    func musicView(_ screenWidth: CGFloat) -> some View {
        if let musicUrl = viewStore.musicInput.selectedMusicUrl {
            MusicPresentingView(url: musicUrl, screenWidth: screenWidth) {
                viewStore.send(.binding(.set(\.$isMusicBottomSheetPresented, true)))
            }
        } else {
            ElementGuideView(element: .music, screenWidth: screenWidth) {
                viewStore.send(.binding(.set(\.$isMusicBottomSheetPresented, true)))
            }
        }
    }

    var bottomButtonsView: some View {
        HStack(spacing: 16) {
            Button {

            } label: {
                Text("박스 다시 고르기")
                    .foregroundStyle(.white)
                    .packyFont(.body4)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background {
                        Capsule()
                    }
            }

            Button {

            } label: {
                HStack(spacing: 8) {
                    Image(.plus)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)

                    Text("선물 담기")
                        .foregroundStyle(.white)
                        .packyFont(.body4)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background {
                    Capsule()
                }
            }
        }
    }
}

private struct ElementGuideView: View {

    let element: BoxElementShape
    let screenWidth: CGFloat
    let action: () -> Void

    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    var body: some View {
        Button {
            HapticManager.shared.fireFeedback(.medium)
            action()
        } label: {
            let size = element.size(fromScreenWidth: screenWidth)
            RoundedRectangle(cornerRadius: 8)
                .stroke(element.hasBorder ? .white : .clear, style: strokeStyle)
                .contentShape(Rectangle())
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(element.rotationDegree))
                .overlay {
                    VStack(spacing: 8) {
                        element.image
                            .renderingMode(.template)
                            .foregroundStyle(.white)

                        if !element.title.isEmpty {
                            Text(element.title)
                                .packyFont(.body4)
                                .foregroundStyle(.white)
                        }
                    }
                }
        }
        .buttonStyle(.bouncy)
    }
}

private struct PhotoPresentingView: View {
    let photoUrl: URL
    let screenWidth: CGFloat
    let action: () -> Void

    private let element = BoxElementShape.photo

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)

        Button {
            action()
        } label: {
            VStack {
                KFImage(photoUrl)
                    .placeholder {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                Spacer()
            }
            .frame(width: size.width, height: size.height)
            .background(.white)
            .rotationEffect(.degrees(element.rotationDegree))
        }
        .buttonStyle(.bouncy)
    }
}

private struct LetterPresentingView: View {
    let input: BoxStartGuideFeature.LetterInput
    let screenWidth: CGFloat
    let action: () -> Void

    private let element = BoxElementShape.letter
    private let letterContentWidthRatio: CGFloat = 160 / 180
    private let letterContentHeightRatio: CGFloat = 130 / 150

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)
        let letterContentWidth = letterContentWidthRatio * size.width
        let letterContentHeight = letterContentHeightRatio * size.height
        let spacing = letterContentWidth * (20 / 160)

        Button {
            action()
        } label: {
            ZStack {
                Text(input.letter)
                    .packyFont(.body6)
                    .foregroundStyle(.gray900)
                    .padding(8)
                    .frame(width: letterContentWidth, height: letterContentHeight, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                    )

                // TODO: input.templateIndex 적용
                Image(.envelopeSample)
                    .resizable()
                    .frame(width: letterContentWidth, height: letterContentHeight, alignment: .top)
                    .offset(x: spacing, y: spacing)
            }
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(element.rotationDegree))
        }
        .buttonStyle(.bouncy)
    }
}

private struct MusicPresentingView: View {
    let url: String
    let screenWidth: CGFloat
    let action: () -> Void

    private let element = BoxElementShape.music

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)

        YouTubePlayerView(.init(stringLiteral: url)) { state in
            switch state {
            case .idle:
                ProgressView()
            case .ready:
                EmptyView()
            case .error:
                Text("문제가 생겼어요")
                    .packyFont(.body1)
            }
        }
        .frame(width: size.width, height: size.height)
        .mask(RoundedRectangle(cornerRadius: 8))
        .onLongPressGesture {
            action()
        }
    }
}


// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, selectedBoxIndex: 0),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
