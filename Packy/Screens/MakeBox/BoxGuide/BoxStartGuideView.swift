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

    @State var selectedTempMusic: TempMusic? = TempMusic.musics.first

    private let strokeColor: Color = .gray400
    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    init(store: StoreOf<BoxStartGuideFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ScrollView {
                VStack {
                    // 음악 추가 원
                    let musicCircleSize = BoxElementShape.musicCircle.relativeSize(geometryWidth: width)
                    Circle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: musicCircleSize.width, height: musicCircleSize.height)

                    // 편지 추가 사각형
                    let letterRectangleSize = BoxElementShape.letterRectangle.relativeSize(geometryWidth: width)
                    Rectangle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: letterRectangleSize.width, height: letterRectangleSize.height)

                    // 사진 추가
                    let photoRectangleSize = BoxElementShape.photoRectangle.relativeSize(geometryWidth: width)
                    Rectangle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: photoRectangleSize.width, height: photoRectangleSize.height)

                    // 음악 원
                    let giftEllipseSize = BoxElementShape.giftEllipse.relativeSize(geometryWidth: width)
                    Ellipse()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: giftEllipseSize.width, height: giftEllipseSize.height)
                }
            }
        }
        .bottomSheet(
            isPresented: viewStore.$isMusicBottomSheetPresented, 
            currentDetent: .constant(viewStore.musicBottomSheetMode.detent),
            detents: viewStore.musicSheetDetents,
            showLeadingButton: viewStore.musicBottomSheetMode != .choice,
            leadingButtonAction: { viewStore.send(.musicBottomSheetBackButtonTapped) }
        )  {
            VStack {
                switch viewStore.musicBottomSheetMode {
                case .choice:
                    musicAddChoiceBottomSheet
                case .userSelect:
                    musicUserSelectBottomSheet
                case .recommend:
                    musicRecommendationBottomSheet
                }
            }
            .animation(.easeInOut, value: viewStore.musicBottomSheetMode.detent)
        }
        .bottomSheet(
            isPresented: viewStore.$isPhotoBottomSheetPresented,
            detents: [.large]
        ) {
            addPhotoBottomSheet
        }
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
            initialState: .init(),
            reducer: {
                BoxStartGuideFeature()
                    // ._printChanges()
            }
        )
    )
}
