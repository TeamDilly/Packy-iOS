//
//  MainTabView+ArchiveOverlay.swift
//  Packy
//
//  Created by Mason Kim on 2/23/24.
//

import SwiftUI

extension MainTabView {
    /// 화면 전체를 덮는 overlay 형태로 처리해야 하기에 MainTabView 에서 overlay 로 처리
    func archiveOverlay<Body: View>(body: () -> Body) -> some View {
        body()
            .dimmedOverlay(isPresented: photoPresentBinding) {
                photoOverlayView
            }
            .dimmedOverlay(isPresented: letterPresentBinding) {
                letterOverlayView
            }
            .dimmedOverlay(isPresented: musicPresentBinding) {
                musicOverlayView
            }
            .dimmedOverlay(isPresented: giftPresentBinding) {
                giftOverlayView
            }
    }
}

// MARK: - Private

private extension MainTabView {
    @ViewBuilder
    var photoOverlayView: some View {
        if let photo = viewStore.archive.photoArchive.selectedPhoto {
            BoxDetailPhotoView(
                imageUrl: photo.photoUrl,
                text: photo.description
            )
        }
    }

    @ViewBuilder
    var letterOverlayView: some View {
        if let letter = viewStore.archive.letterArchive.selectedLetter {
            BoxDetailLetterView(
                text: letter.letterContent,
                borderColor: Color(hexString: letter.envelope.borderColorCode)
            )
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    var musicOverlayView: some View {
        if let music = viewStore.archive.musicArchive.selectedMusic {
            MusicPlayerView(youtubeUrl: music.youtubeUrl)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    var giftOverlayView: some View {
        if let gift = viewStore.archive.giftArchive.selectedGift {
            ImageViewer {
                NetworkImage(url: gift.gift.url, contentMode: .fit)
            } dismissedImage: {
                giftPresentBinding.wrappedValue = false
            }
            .padding(50)
        }
    }

    var photoPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.archive.photoArchive.selectedPhoto != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.archive(.binding(.set(\.photoArchive.$selectedPhoto, nil))))
            }
        )
    }

    var letterPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.archive.letterArchive.selectedLetter != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.archive(.binding(.set(\.letterArchive.$selectedLetter, nil))))
            }
        )
    }

    var musicPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.archive.musicArchive.selectedMusic != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.archive(.binding(.set(\.musicArchive.$selectedMusic, nil))))
            }
        )
    }

    var giftPresentBinding: Binding<Bool> {
        .init(
            get: { viewStore.archive.giftArchive.selectedGift != nil },
            set: {
                guard $0 == false else { return }
                viewStore.send(.archive(.binding(.set(\.giftArchive.$selectedGift, nil))))
            }
        )
    }
}
