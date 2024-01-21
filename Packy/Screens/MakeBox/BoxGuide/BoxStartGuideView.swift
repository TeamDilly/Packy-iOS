//
//  BoxStartGuideView.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxStartGuideView: View {
    private let store: StoreOf<BoxStartGuideFeature>
    @ObservedObject var viewStore: ViewStoreOf<BoxStartGuideFeature>

    @State var selectedTempMusic: TempMusic? = TempMusic.musics.first!

    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    init(store: StoreOf<BoxStartGuideFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            let photoSize = BoxElementShape.photo.size(fromScreenWidth: screenWidth)
            let stickerSize = BoxElementShape.sticker.size(fromScreenWidth: screenWidth)
            let letterSize = BoxElementShape.letter.size(fromScreenWidth: screenWidth)
            let musicSize = BoxElementShape.music.size(fromScreenWidth: screenWidth)

            VStack(spacing: 0) {
                FloatingNavigationBar {
                    viewStore.send(.nextButtonTapped)
                }

                HStack {
                    // 추억 사진 담기
                    Button {
                        viewStore.send(.binding(.set(\.$isPhotoBottomSheetPresented, true)))
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, style: strokeStyle)
                            .frame(width: photoSize.width, height: photoSize.height)
                            .rotationEffect(.degrees(-3))
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(.photo)
                                        .renderingMode(.template)
                                        .foregroundStyle(.white)
                                    Text("추억 사진 담기")
                                        .packyFont(.body4)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.bouncy)

                    Spacer()

                    // 스티커1
                    Button {
                        // 스티커1 추가
                    } label: {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: stickerSize.width, height: stickerSize.height)
                            .rotationEffect(.degrees(10))
                            .overlay {
                                Image(.plusSquareDashed)
                                    .renderingMode(.template)
                                    .foregroundStyle(.white)
                            }
                            .contentShape(Rectangle())
                    }
                    .offset(y: 10)
                    .buttonStyle(.bouncy)
                }
                .padding(.leading, 33)
                .padding(.trailing, 36)
                .padding(.top, 36)

                HStack {
                    // 스티커2
                    Button {
                        // 스티커2 추가
                    } label: {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: stickerSize.width, height: stickerSize.height)
                            .rotationEffect(.degrees(-10))
                            .overlay {
                                Image(.plusSquareDashed)
                                    .renderingMode(.template)
                                    .foregroundStyle(.white)
                            }
                            .contentShape(Rectangle())
                    }
                    .offset(y: -5)
                    .buttonStyle(.bouncy)

                    Spacer()

                    // 편지 쓰기
                    Button {
                        viewStore.send(.binding(.set(\.$isLetterBottomSheetPresented, true)))
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, style: strokeStyle)
                            .frame(width: letterSize.width, height: letterSize.height)
                            .rotationEffect(.degrees(3))
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(.envelope)
                                        .renderingMode(.template)
                                        .foregroundStyle(.white)
                                    Text("편지 쓰기")
                                        .packyFont(.body4)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.bouncy)
                }
                .padding(.leading, 36)
                .padding(.trailing, 33)
                .padding(.top, 36)

                // 음악 추가하기
                Button {
                    viewStore.send(.binding(.set(\.$isMusicBottomSheetPresented, true)))
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, style: strokeStyle)
                        .frame(width: musicSize.width, height: musicSize.height)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(.musicNote)
                                    .renderingMode(.template)
                                    .foregroundStyle(.white)
                                Text("음악 추가하기")
                                    .packyFont(.body4)
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.bouncy)
                .padding(.horizontal, 32)
                .padding(.top, 43)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .background(Color.init(hex: 0x222222))
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
        .alertButtonTint(color: .black)
        .alert(store: store.scope(state: \.$boxFinishAlert, action: \.boxFinishAlert))
        .accentColor(.black)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views


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
