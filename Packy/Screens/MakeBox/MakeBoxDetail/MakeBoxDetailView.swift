//
//  MakeBoxDetailView.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

// MARK: - View

struct MakeBoxDetailView: View {
    @Bindable private var store: StoreOf<MakeBoxDetailFeature>

    @State private var isShowingGuideText: Bool = false

    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    init(store: StoreOf<MakeBoxDetailFeature>) {
        self.store = store
    }

    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width

            ZStack(alignment: .topTrailing) {
                if store.isShowingGuideText {
                    guideOverlayView
                        .zIndex(3)
                } else {
                    if let boxTopUrl = store.selectedBox?.boxTopUrl {
                        KFImage(URL(string: boxTopUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.7)
                            .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
                            .ignoresSafeArea()
                            .zIndex(1)
                            .id(store.selectedBox?.id)
                    }

                    FloatingNavigationBar(
                        leadingAction: {
                            store.send(.backButtonTapped)
                        },
                        trailingType: .text("완성"),
                        trailingAction: {
                            store.send(.completeButtonTapped)
                        },
                        trailingDisabled: !store.isCompletable
                    )
                    .zIndex(2)
                }

                VStack(spacing: 0) {
                    ZStack {
                        Text("To. \(store.senderInfo.receiver)")
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
            isPresented: $store.selectMusic.isMusicBottomSheetPresented,
            currentDetent: .constant(store.selectMusic.musicInput.musicBottomSheetMode.detent),
            detents: store.selectMusic.musicInput.musicSheetDetents,
            showLeadingButton: store.selectMusic.musicInput.musicBottomSheetMode != .choice,
            leadingButtonAction: { store.send(.selectMusic(.musicBottomSheetBackButtonTapped)) },
            closeButtonAction: { store.send(.selectMusic(.musicBottomSheetCloseButtonTapped)) },
            isDismissible: false
        )  {
            SelectMusicBottomSheet(store: store.scope(state: \.selectMusic, action: \.selectMusic))
        }
        // 사진 추가 바텀시트
        .bottomSheet(
            isPresented: $store.addPhoto.isPhotoBottomSheetPresented,
            detents: [.large],
            closeButtonAction: { store.send(.addPhoto(.photoBottomSheetCloseButtonTapped)) },
            isDismissible: false
        ) {
            AddPhotoBottomSheet(store: store.scope(state: \.addPhoto, action: \.addPhoto))
        }
        // 편지 쓰기 바텀시트
        .bottomSheet(
            isPresented: $store.writeLetter.isWriteLetterBottomSheetPresented,
            detents: [.large],
            closeButtonAction: { store.send(.writeLetter(.WriteLetterBottomSheetCloseButtonTapped)) },
            isDismissible: false
        ) {
            WriteLetterBottomSheet(store: store.scope(state: \.writeLetter, action: \.writeLetter))
        }
        // 스티커 추가 바텀 시트
        .bottomSheet(
            isPresented: $store.selectSticker.isStickerBottomSheetPresented,
            detents: [.fraction(0.35)],
            isBackgroundBlack: false,
            hideTopButtons: true
        ) {
            SelectStickerBottomSheet(store: store.scope(state: \.selectSticker, action: \.selectSticker))
        }
        // 박스 다시 고르기 바텀 시트
        .bottomSheet(
            isPresented: $store.isSelectBoxBottomSheetPresented,
            detents: [.fraction(0.3)],
            isBackgroundBlack: false,
            hideTopButtons: true
        ) {
            SelectBoxBottomSheet(store: store)
        }
        // 선물 추가 바텀 시트
        .bottomSheet(
            isPresented: $store.addGift.isAddGiftBottomSheetPresented,
            detents: [.large],
            closeButtonAction: {
                store.send(.addGift(.addGiftSheetCloseButtonTapped))
            },
            isDismissible: false
        ) {
            AddGiftBottomSheet(store: store.scope(state: \.addGift, action: \.addGift))
        }
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
        .popGestureOnlyDisabled()
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension MakeBoxDetailView {
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
        if let image = store.addPhoto.savedPhoto.photoData?.image {
            PhotoElementView(image: image, screenWidth: screenWidth) {
                store.send(.addPhoto(.photoSelectButtonTapped))
            }
        } else {
            ElementGuideView(element: .photo, screenWidth: screenWidth) {
                store.send(.addPhoto(.photoSelectButtonTapped))
            }
        }
    }

    @ViewBuilder
    func letterView(_ screenWidth: CGFloat) -> some View {
        if store.writeLetter.savedLetter.isCompleted {
            LetterElementView(
                lettetContent: store.writeLetter.savedLetter.letter,
                letterImageUrl: store.writeLetter.savedLetter.selectedLetterDesign?.imageUrl ?? "",
                screenWidth: screenWidth
            ) {
                store.send(.writeLetter(.letterInputButtonTapped))
            }
        } else {
            ElementGuideView(element: .letter, screenWidth: screenWidth) {
                store.send(.writeLetter(.letterInputButtonTapped))
            }
        }
    }

    @ViewBuilder
    func musicView(_ screenWidth: CGFloat) -> some View {
        if let musicUrl = store.selectMusic.savedMusic.selectedMusicUrl {
            MusicElementView(
                youtubeUrl: musicUrl,
                screenWidth: screenWidth,
                deleteAction: {
                    store.send(.selectMusic(.musicLinkDeleteButtonTapped))
                },
                isPresentCloseButton: true
            )
        } else {
            ElementGuideView(element: .music, screenWidth: screenWidth) {
                store.send(.selectMusic(.musicSelectButtonTapped))
            }
        }
    }

    @ViewBuilder
    func firstStickerView(_ screenWidth: CGFloat) -> some View {
        if let firstSticker = store.selectSticker.selectedStickers.first {
            StickerElementView(
                stickerType: .sticker1,
                stickerURL: firstSticker.imageUrl,
                screenWidth: screenWidth
            ) {
                store.send(.selectSticker(.stickerInputButtonTapped))
            }
        } else {
            ElementGuideView(element: .sticker1, screenWidth: screenWidth) {
                store.send(.selectSticker(.stickerInputButtonTapped))
            }
        }
    }

    @ViewBuilder
    func secondStickerView(_ screenWidth: CGFloat) -> some View {
        if let secondSticker = store.selectSticker.selectedStickers[safe: 1] {
            StickerElementView(
                stickerType: .sticker2,
                stickerURL: secondSticker.imageUrl,
                screenWidth: screenWidth
            ) {
                store.send(.selectSticker(.stickerInputButtonTapped))
            }
        } else {
            ElementGuideView(element: .sticker2, screenWidth: screenWidth) {
                store.send(.selectSticker(.stickerInputButtonTapped))
            }
        }
    }

    var bottomButtonsView: some View {
        HStack(spacing: 16) {
            Button {
                store.send(.binding(.set(\.isSelectBoxBottomSheetPresented, true)))
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

            let isGiftAdded: Bool = store.addGift.savedGift.photoData != nil
            Button {
                store.send(.addGift(.addGiftButtonTapped))
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

    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [8])

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)
        RoundedRectangle(cornerRadius: 8)
            .stroke(
                element.hasBorder ? .white.opacity(0.3) : .clear,
                style: strokeStyle
            )
            .contentShape(Rectangle())
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(element.rotationDegree))
            .overlay {
                VStack(spacing: element.iconTextSpacing) {
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
    MakeBoxDetailView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                MakeBoxDetailFeature()
                    ._printChanges()
            }
        )
    )
}
