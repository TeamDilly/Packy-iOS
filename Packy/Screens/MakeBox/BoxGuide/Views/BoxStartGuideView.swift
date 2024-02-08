//
//  BoxStartGuideView.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

// MARK: - View

struct BoxStartGuideView: View {
    private let store: StoreOf<BoxStartGuideFeature>
    @ObservedObject var viewStore: ViewStoreOf<BoxStartGuideFeature>

    @State private var isShowingGuideText: Bool = false

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
                    if let boxTopUrl = viewStore.selectedBox?.boxTopUrl {
                        KFImage(URL(string: boxTopUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.7)
                            .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
                            .ignoresSafeArea()
                            .zIndex(1)
                            .id(viewStore.selectedBox?.id)
                    }

                    FloatingNavigationBar(
                        leadingAction: {
                            viewStore.send(.backButtonTapped)
                        },
                        trailingType: .text("완성"),
                        trailingAction: {
                            viewStore.send(.completeButtonTapped)
                        },
                        trailingDisabled: !viewStore.isCompletable
                    )
                    .zIndex(2)
                }

                VStack(spacing: 0) {
                    ZStack {
                        Text("To. \(viewStore.senderInfo.receiver)")
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
            isPresented: viewStore.$addPhoto.isPhotoBottomSheetPresented,
            detents: [.large],
            closeButtonAction: { viewStore.send(.addPhoto(.photoBottomSheetCloseButtonTapped)) },
            isDismissible: false
        ) {
            AddPhotoBottomSheet(store: store.scope(state: \.addPhoto, action: \.addPhoto))
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
        .popGestureOnlyDisabled()
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
        return ZStack {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()

            Text("빈 공간을 눌러서\n선물박스를 채워보세요")
                .packyFont(.heading2)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .textInteraction()
        }
        .onAppear {
            isShowingGuideText = true
        }
        .zIndex(1)
    }

    @ViewBuilder
    func photoView(_ screenWidth: CGFloat) -> some View {
        if let photoUrl = viewStore.addPhoto.savedPhoto.photoUrl {
            PhotoElementView(
                photoUrl: photoUrl,
                screenWidth: screenWidth
            ) {
                viewStore.send(.addPhoto(.photoSelectButtonTapped))
            }
        } else {
            ElementGuideView(element: .photo, screenWidth: screenWidth) {
                viewStore.send(.addPhoto(.photoSelectButtonTapped))
            }
        }
    }

    @ViewBuilder
    func letterView(_ screenWidth: CGFloat) -> some View {
        if viewStore.savedLetter.isCompleted {
            LetterElementView(
                lettetContent: viewStore.savedLetter.letter,
                letterImageUrl: viewStore.savedLetter.selectedLetterDesign?.imageUrl ?? "",
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
            MusicElementView(
                youtubeUrl: musicUrl,
                screenWidth: screenWidth,
                isPresentCloseButton: true
            ) {
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
            StickerElementView(
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
            StickerElementView(
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

            let isGiftAdded: Bool = viewStore.savedGift.imageUrl != nil
            Button {
                viewStore.send(.addGiftButtonTapped)
            } label: {
                HStack(spacing: 8) {
                    Image(isGiftAdded ? .check : .plus)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)

                    Text(isGiftAdded ? "담은 선물 보기" : "선물 담기")
                        .foregroundStyle(.white)
                        .packyFont(.body4)
                }
                .animation(.spring(duration: 1).delay(0.5), value: isGiftAdded)
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
            .bouncyTapGesture {
                action()
            }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
