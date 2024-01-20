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

    private let strokeColor: Color = .gray400
    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    init(store: StoreOf<BoxStartGuideFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                FloatingNavigationBar {
                    viewStore.send(.nextButtonTapped)
                }

                PackyButton(title: "Music") {
                    viewStore.send(.binding(.set(\.$isMusicBottomSheetPresented, true)))
                }
                .padding()

                PackyButton(title: "Photo") {
                    viewStore.send(.binding(.set(\.$isPhotoBottomSheetPresented, true)))
                }
                .padding()

                Spacer()
            }
        }
        // 음악 추가 바텀시트
        .bottomSheet(
            isPresented: viewStore.$isMusicBottomSheetPresented, 
            currentDetent: .constant(viewStore.musicInput.musicBottomSheetMode.detent),
            detents: viewStore.musicInput.musicSheetDetents,
            showLeadingButton: viewStore.musicInput.musicBottomSheetMode != .choice,
            leadingButtonAction: { viewStore.send(.musicBottomSheetBackButtonTapped) }
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
            detents: [.large]
        ) {
            addPhotoBottomSheet
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
