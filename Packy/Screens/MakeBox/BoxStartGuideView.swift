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
    @ObservedObject private var viewStore: ViewStoreOf<BoxStartGuideFeature>

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
            detents: [viewStore.musicBottomSheetMode.detents],
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
                    Text("")
                }
            }
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxStartGuideView {
    var musicAddChoiceBottomSheet: some View {
        VStack(spacing: 0) {
            Text("음악 추가하기")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.bottom, 24)

            MusicSelectionCell(
                title: "직접 음악 선택하기",
                caption: "유튜브 링크로 음악을 넣어주세요") {
                    viewStore.send(.musicChoiceUserSelectButtonTapped)
                }
                .padding(.bottom, 8)

            MusicSelectionCell(
                title: "패키의 음악으로 담기",
                caption: "다양한 테마의 음악들을 준비했어요!") {
                    viewStore.send(.musicChoiceRecommendButtonTapped)
                }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    var musicUserSelectBottomSheet: some View {
        VStack(spacing: 0) {
            Text("들려주고 싶은 음악")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.bottom, 4)

            Text("유튜브 영상 url을 넣어주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                PackyTextField(text: viewStore.$musicLinkUrl, placeholder: "링크를 붙여주세요")

                PackyButton(title: "확인", sizeType: .medium, colorType: .black) {
                    viewStore.send(.musicLinkConfirmButtonTapped)
                }
                .frame(width: 100)
            }
            .padding(.top, 32)

            Spacer()

            PackyButton(title: "저장", colorType: .black) {
                viewStore.send(.musicLinkSaveButtonTapped)
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
    }
}

private struct MusicSelectionCell: View {
    let title: String
    let caption: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(spacing: 2) {
                    Text(title)
                        .packyFont(.body1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(caption)
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Image(.arrowRight)
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray100)
            }
        }
    }
}

// MARK: - MusicBottomSheet Detents

private extension BoxStartGuideFeature.MusicBottomSheetMode {
    var detents: PresentationDetent {
        switch self {
        case .choice:
            return .height(383)
        case .userSelect, .recommend:
            return .large
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
