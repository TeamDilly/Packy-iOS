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
            let stickerSize = BoxElementShape.sticker1.size(fromScreenWidth: screenWidth)
            let letterSize = BoxElementShape.letter.size(fromScreenWidth: screenWidth)
            let musicSize = BoxElementShape.music.size(fromScreenWidth: screenWidth)

            ZStack {
                if viewStore.isShowingGuideText {
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

                VStack(spacing: 0) {
                    FloatingNavigationBar {
                        viewStore.send(.nextButtonTapped)
                    }

                    HStack {
                        // 추억 사진 담기
                        ElementGuideView(element: .photo, screenWidth: screenWidth) {
                            viewStore.send(.binding(.set(\.$isPhotoBottomSheetPresented, true)))
                        }

                        Spacer()

                        // 스티커1
                        ElementGuideView(element: .sticker1, screenWidth: screenWidth) {
                            // 스티커1 추가
                        }
                        .offset(y: 10)
                    }
                    .padding(.leading, 33)
                    .padding(.trailing, 36)
                    .padding(.top, 36)

                    HStack {
                        // 스티커2
                        ElementGuideView(element: .sticker2, screenWidth: screenWidth) {
                            // 스티커2 추가
                        }
                        .offset(y: -5)

                        Spacer()

                        // 편지 쓰기
                        ElementGuideView(element: .letter, screenWidth: screenWidth) {
                            viewStore.send(.binding(.set(\.$isLetterBottomSheetPresented, true)))
                        }
                    }
                    .padding(.leading, 36)
                    .padding(.trailing, 33)
                    .padding(.top, 36)

                    // 음악 추가하기
                    ElementGuideView(element: .music, screenWidth: screenWidth) {
                        viewStore.send(.binding(.set(\.$isMusicBottomSheetPresented, true)))
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 43)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .background(Color.init(hex: 0x222222))
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
        .alertButtonTint(color: .black)
        .alert(store: store.scope(state: \.$boxFinishAlert, action: \.boxFinishAlert))
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

private struct ElementGuideView: View {

    let element: BoxElementShape
    let screenWidth: CGFloat
    let action: () -> Void

    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    var body: some View {
        Button {
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
