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

            ZStack(alignment: .topTrailing) {
                if viewStore.isShowingGuideText {
                    guideOverlayView
                        .zIndex(3)
                } else {
                    if let selectedBox = viewStore.selectedBox {
                        KFImage(URL(string: selectedBox.boxPartUrl))
                            .zIndex(1)
                            .ignoresSafeArea()
                            .transition(.move(edge: .top))
                    }

                    FloatingNavigationBar(
                        trailingTitle: "완성",
                        trailingAction: {
                            viewStore.send(.completeButtonTapped)
                        },
                        trailingDisabled: !viewStore.isCompletable
                    )
                    .zIndex(2)
                }

                VStack(spacing: 0) {
                    ZStack {
                        Text("To. \(viewStore.senderInfo.to)")
                            .packyFont(.body2)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 72)

                        Rectangle()
                            .fill(.clear)
                            .frame(height: 48)
                    }

                    HStack {
                        // 추억 사진 담기
                        photoView(screenWidth)

                        Spacer()

                        // 스티커1
                        firstStickerView(screenWidth)
                            .offset(y: 10)
                    }
                    .padding(.leading, 33)
                    .padding(.trailing, 36)
                    .padding(.top, 36)

                    HStack {
                        // 스티커2
                        secondStickerView(screenWidth)

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
            closeButtonAction: { viewStore.send(.musicBottomSheetCloseButtonTapped) },
            isDismissible: false
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
            closeButtonAction: { viewStore.send(.photoBottomSheetCloseButtonTapped) },
            isDismissible: false
        ) {
            addPhotoBottomSheet
        }
        // 편지 쓰기 바텀시트
        .bottomSheet(
            isPresented: viewStore.$isLetterBottomSheetPresented,
            detents: [.large],
            closeButtonAction: { viewStore.send(.letterBottomSheetCloseButtonTapped) },
            isDismissible: false
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
        // 박스 다시 고르기 바텀 시트
        .bottomSheet(
            isPresented: viewStore.$isSelectBoxBottomSheetPresented,
            detents: [.fraction(0.3)],
            isBackgroundBlack: false,
            hideTopButtons: true
        ) {
            selectBoxBottomSheet
        }
        // 선물 추가 바텀 시트
        .bottomSheet(
            isPresented: viewStore.$isAddGiftBottomSheetPresented,
            detents: [.large],
            closeButtonAction: {
                viewStore.send(.addGiftSheetCloseButtonTapped)
            },
            isDismissible: false
        ) {
            addGiftBottomSheet
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
        if let photoUrl = viewStore.savedPhoto.photoUrl {
            PhotoPresentingView(
                photoUrl: photoUrl,
                screenWidth: screenWidth
            ) {
                viewStore.send(.photoSelectButtonTapped)
            }
        } else {
            ElementGuideView(element: .photo, screenWidth: screenWidth) {
                viewStore.send(.photoSelectButtonTapped)
            }
        }
    }

    @ViewBuilder
    func letterView(_ screenWidth: CGFloat) -> some View {
        if viewStore.savedLetter.isCompleted {
            LetterPresentingView(
                input: viewStore.savedLetter,
                screenWidth: screenWidth
            ) {
                viewStore.send(.letterInputButtonTapped)
            }
        } else {
            ElementGuideView(element: .letter, screenWidth: screenWidth) {
                viewStore.send(.letterInputButtonTapped)
            }
        }
    }

    @ViewBuilder
    func musicView(_ screenWidth: CGFloat) -> some View {
        if let musicUrl = viewStore.savedMusic.selectedMusicUrl {
            MusicPresentingView(url: musicUrl, screenWidth: screenWidth) {
                viewStore.send(.musicLinkDeleteButtonTapped)
            }
        } else {
            ElementGuideView(element: .music, screenWidth: screenWidth) {
                viewStore.send(.musicSelectButtonTapped)
            }
        }
    }

    @ViewBuilder
    func firstStickerView(_ screenWidth: CGFloat) -> some View {
        if let firstSticker = viewStore.selectedStickers.first {
            StickerPresentingView(
                stickerType: .sticker1,
                stickerURL: firstSticker.imageUrl,
                screenWidth: screenWidth) {
                    viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, true)))
                }
        } else {
            ElementGuideView(element: .sticker1, screenWidth: screenWidth) {
                viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, true)))
            }
        }
    }

    @ViewBuilder
    func secondStickerView(_ screenWidth: CGFloat) -> some View {
        if let secondSticker = viewStore.selectedStickers[safe: 1] {
            StickerPresentingView(
                stickerType: .sticker2,
                stickerURL: secondSticker.imageUrl,
                screenWidth: screenWidth) {
                    viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, true)))
                }
        } else {
            ElementGuideView(element: .sticker2, screenWidth: screenWidth) {
                viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, true)))
            }
        }
    }

    var bottomButtonsView: some View {
        HStack(spacing: 16) {
            Button {
                viewStore.send(.binding(.set(\.$isSelectBoxBottomSheetPresented, true)))
            } label: {
                Text("박스 다시 고르기")
                    .foregroundStyle(.white)
                    .packyFont(.body4)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background {
                        Capsule()
                            .fill(.black.opacity(0.3))
                    }
            }

            Button {
                viewStore.send(.binding(.set(\.$isAddGiftBottomSheetPresented, true)))
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
                        .fill(.black.opacity(0.3))
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
            HapticManager.shared.fireFeedback(.soft)
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
    let photoUrl: String
    let screenWidth: CGFloat
    let action: () -> Void

    private let element = BoxElementShape.photo

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)

        Button {
            HapticManager.shared.fireFeedback(.soft)
            action()
        } label: {
            VStack {
                NetworkImage(url: photoUrl)
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
            HapticManager.shared.fireFeedback(.soft)
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

                if let imageUrl = input.selectedLetterDesign?.imageUrl {
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .frame(width: letterContentWidth, height: letterContentHeight, alignment: .top)
                        .offset(x: spacing, y: spacing)
                }
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
    let deleteAction: () -> Void

    private let element = BoxElementShape.music
    private var size: CGSize {
        element.size(fromScreenWidth: screenWidth)
    }

    var body: some View {
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
        .overlay(alignment: .topTrailing) {
            CloseButton(sizeType: .medium, colorType: .light) {
                deleteAction()
            }
            .offset(x: 4, y: -4)
        }
    }
}

private struct StickerPresentingView: View {
    let stickerType: BoxElementShape
    let stickerURL: String
    let screenWidth: CGFloat
    let action: () -> Void

    private var size: CGSize {
        stickerType.size(fromScreenWidth: screenWidth)
    }

    var body: some View {
        Button {
            HapticManager.shared.fireFeedback(.soft)
            action()
        } label: {
            KFImage(URL(string: stickerURL))
                .placeholder {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .scaleToFillFrame(width: size.width, height: size.height)
                .rotationEffect(.degrees(stickerType.rotationDegree))
        }
    }
}


// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock, savedPhoto: .init(photoUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/images/ebe6d8ba-7a04-4f18-bcea-57197bf789b1-9E448F3C-10DD-414E-8692-2DF5BB997522.png")),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
