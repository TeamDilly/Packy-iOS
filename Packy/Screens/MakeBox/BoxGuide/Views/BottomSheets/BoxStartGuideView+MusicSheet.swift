//
//  BoxStartGuideView+MusicSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/19/24.
//

import SwiftUI
import YouTubePlayerKit

// TODO: 하위 뷰, 리듀서로 분리

extension BoxStartGuideView {

    // MARK: 음악 추가 방식 선택 바텀시트

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

    // MARK: 음악 직접 입력 바텀시트

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

            if let selectedMusicUrl = viewStore.musicInput.selectedMusicUrl {
                YouTubePlayerView(.init(stringLiteral: selectedMusicUrl)) { state in
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
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .topTrailing) {
                    CloseButton(sizeType: .medium, colorType: .dark) {
                        viewStore.send(.musicLinkDeleteButtonInSheetTapped)
                    }
                    .offset(x: 4, y: -4)
                }
                .padding(.top, 32)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    PackyTextField(
                        text: viewStore.$musicInput.musicLinkUrlInput,
                        placeholder: "링크를 붙여주세요",
                        errorMessage: viewStore.musicInput.showInvalidMusicUrlError ? "올바른 url을 입력해주세요" : nil
                    )

                    PackyButton(title: "확인", sizeType: .medium, colorType: .black) {
                        viewStore.send(.musicLinkConfirmButtonTapped)
                    }
                    .frame(width: 100)
                }
                .padding(.top, 32)
            }

            Spacer()

            PackyButton(title: "저장", colorType: .black) {
                viewStore.send(.musicSaveButtonTapped)
            }
            .disabled(
                viewStore.musicInput.musicBottomSheetMode == .userSelect
                && viewStore.musicInput.selectedMusicUrl == nil
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
    }

    // MARK: 추천 음악 선택 바텀시트

    var musicRecommendationBottomSheet: some View {
            VStack(spacing: 0) {
                Group {
                    Text("패키가 준비한 음악 담기")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    Text("특별한 날을 더욱 기억에 남게 할 음악을 준비했어요")
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                .padding(.horizontal, 24)

                Spacer()

                // FIXME: 차후) 무한 캐러셀 구현
                
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(viewStore.recommendedMusics, id: \.self) { music in
                            VStack(spacing: 0) {
                                YouTubePlayerView(.init(stringLiteral: music.youtubeUrl)) { state in
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
                                .aspectRatio(16 / 9, contentMode: .fit)
                                .padding(.bottom, 16)

                                Text(music.title)
                                    .packyFont(.body1)
                                    .foregroundStyle(.gray900)

                                Text(music.hashtags.joined(separator: " "))
                                    .packyFont(.body4)
                                    .foregroundStyle(.purple500)
                                    .padding(.bottom, 16)
                            }
                            .background(.gray100)
                            .mask(RoundedRectangle(cornerRadius: 16))
                            .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: .init(
                    get: { viewStore.musicInput.selectedRecommendedMusic },
                    set: { viewStore.send(.binding(.set(\.musicInput.$selectedRecommendedMusic, $0))) }
                ))
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 32)

                let selectedRecommendedMusic = viewStore.musicInput.selectedRecommendedMusic
                let musicIndex = viewStore.recommendedMusics.firstIndex { $0.id == selectedRecommendedMusic?.id ?? 0 } ?? 0
                PageIndicator(totalPages: viewStore.recommendedMusics.count, currentPage: musicIndex)
                    .padding(.vertical, 32)

                Spacer()

                PackyButton(title: "저장", colorType: .black) {
                    viewStore.send(.musicSaveButtonTapped)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
    }
}

extension RecommendedMusic: Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - MusicSelectionCell

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

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock, isMusicBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
            }
        )
    )
}
