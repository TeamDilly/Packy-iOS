//
//  BoxStartGuideView+MusicSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/19/24.
//

import SwiftUI
import YouTubePlayerKit

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

            if let musicLinkPlayer = viewStore.selectedMusicUrl {
                YouTubePlayerView(musicLinkPlayer) { state in
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
                .frame(height: 183)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .topTrailing) {
                    CloseButton(sizeType: .medium, colorType: .dark) {
                        viewStore.send(.musicLinkDeleteButtonTapped)
                    }
                    .offset(x: 4, y: -4)
                }
                .padding(.top, 32)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    PackyTextField(
                        text: viewStore.$musicLinkUrlInput,
                        placeholder: "링크를 붙여주세요",
                        errorMessage: viewStore.showInvalidMusicUrlError ? "올바른 url을 입력해주세요" : nil
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
                viewStore.send(.musicLinkSaveButtonTapped)
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
    }

    // MARK: 추천 음악 선택 바텀시트

    var musicRecommendationBottomSheet: some View {
        VStack {
            Group {
                Text("패키가 준비한 음악")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                Text("음악을 선택해주세요")
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
            .padding(.horizontal, 24)

            CarouselView(items: TempMusic.musics, itemWidth: 180, itemPadding: 40) { music in
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
                .frame(width: 180, height: 180)
                .mask(Circle())
            }
            .minifyScale(160 / 180)
            .centeredItem($selectedTempMusic)
            .frame(height: 180)
            .padding(.top, 128)

            if let selectedTempMusic {
                Text(selectedTempMusic.title)
                    .packyFont(.heading2)
                    .foregroundStyle(.gray900)
                    .padding(.top, 28)

                Text(
                    selectedTempMusic
                        .hashTags
                        .joined(separator: " ")
                )
                .packyFont(.body2)
                .foregroundStyle(.purple500)
            }

            Spacer()

            PackyButton(title: "저장", colorType: .black) {
                viewStore.send(.musicLinkSaveButtonTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

// TODO: 실제 로직으로 대체

struct TempMusic: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String { id.uuidString.prefix(8).lowercased() }
    let hashTags: [String] = [ "#입학", "#취업", "#결혼"]
    let youtubeUrl: String = "https://www.youtube.com/watch?v=neaxGr8_trU&list=RDneaxGr8_trU&start_radio=1"

    static let musics: [TempMusic] = (0...5).map{ _ in TempMusic() }
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
