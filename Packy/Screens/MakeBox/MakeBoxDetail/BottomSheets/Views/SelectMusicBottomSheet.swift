//
//  SelectMusicBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/19/24.
//

import SwiftUI
import ComposableArchitecture

struct SelectMusicBottomSheet: View {
    @Bindable private var store: StoreOf<SelectMusicFeature>

    init(store: StoreOf<SelectMusicFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            switch store.musicInput.musicBottomSheetMode {
            case .choice:
                musicAddChoiceBottomSheet
            case .userSelect:
                musicUserSelectBottomSheet
            case .recommend:
                musicRecommendationBottomSheet
            }
        }
        .animation(.easeInOut, value: store.musicInput.musicBottomSheetMode.detent)
    }
}

// MARK: - Inner Views

private extension SelectMusicBottomSheet {

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
                title: "직접 음악 영상 담기",
                caption: "유튜브 링크로 음악을 넣어주세요") {
                    store.send(.musicChoiceUserSelectButtonTapped)
                }
                .padding(.bottom, 8)
            
            MusicSelectionCell(
                title: "패키가 준비한 음악 담기",
                caption: "기념일에 어울리는 음악을 준비했어요") {
                    store.send(.musicChoiceRecommendButtonTapped)
                }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: 음악 직접 입력 바텀시트
    
    var musicUserSelectBottomSheet: some View {
        VStack(spacing: 0) {
            Text("직접 음악 영상 담기")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            Text("담고 싶은 음악의 유튜브 영상 링크를 붙여 넣어주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let selectedMusicUrl = store.musicInput.selectedMusicUrl {
                MusicPlayerView(youtubeUrl: selectedMusicUrl, autoPlay: false)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        CloseButton(sizeType: .medium, colorType: .dark) {
                            store.send(.musicLinkDeleteButtonInSheetTapped)
                        }
                        .offset(x: 4, y: -4)
                    }
                    .padding(.top, 32)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    PackyTextField(
                        text: $store.musicInput.musicLinkUrlInput,
                        placeholder: "링크를 붙여주세요",
                        errorMessage: store.musicInput.showInvalidMusicUrlError ? "올바른 영상 링크를 입력해주세요" : nil
                    )
                    
                    PackyButton(title: "확인", sizeType: .medium, colorType: .black) {
                        store.send(.musicLinkConfirmButtonTapped)
                    }
                    .frame(width: 100)
                }
                .padding(.top, 32)
            }
            
            Spacer()
            
            PackyButton(title: "저장", colorType: .black) {
                store.send(.musicSaveButtonTapped)
            }
            .disabled(
                store.musicInput.musicBottomSheetMode == .userSelect
                && store.musicInput.selectedMusicUrl == nil
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
            
            // TODO: 차후) 무한 캐러셀 구현 / 재생중일 때 드래그 안되는 현상 해결

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(store.recommendedMusics, id: \.self) { music in
                        VStack(spacing: 0) {
                            // TODO: 다음 스크롤로 넘어가면 일시정지 되도록 처리 가능?
                            MusicPlayerView(youtubeUrl: music.youtubeUrl, autoPlay: false)
                                .aspectRatio(16 / 9, contentMode: .fit)
                                .padding(.bottom, 20)

                            Text(music.title)
                                .packyFont(.body1)
                                .foregroundStyle(.gray900)
                                .padding(.bottom, 2)

                            HStack(spacing: 6) {
                                ForEach(music.hashtags, id: \.self) { hashtag in
                                    Text(hashtag)
                                        .packyFont(.body4)
                                        .foregroundStyle(.purple500)
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                        .background(.gray100)
                        .mask(RoundedRectangle(cornerRadius: 16))
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: .init(
                get: { store.musicInput.selectedRecommendedMusic },
                set: { store.send(.binding(.set(\.musicInput.selectedRecommendedMusic, $0))) }
            ))
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 32)
            
            let selectedRecommendedMusic = store.musicInput.selectedRecommendedMusic
            let musicIndex = store.recommendedMusics.firstIndex { $0.id == selectedRecommendedMusic?.id ?? 0 } ?? 0
            PageIndicator(totalPages: store.recommendedMusics.count, currentPage: musicIndex)
                .padding(.vertical, 32)
            
            Spacer()
            
            PackyButton(title: "저장", colorType: .black) {
                store.send(.musicSaveButtonTapped)
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
    MakeBoxDetailView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                MakeBoxDetailFeature()
            }
        )
    )
}
