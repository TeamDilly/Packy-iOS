//
//  ArchiveClient.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation
import Dependencies
import class Moya.MoyaProvider

// MARK: - Dependency Values

extension DependencyValues {
    var archiveClient: ArchiveClient {
        get { self[ArchiveClient.self] }
        set { self[ArchiveClient.self] = newValue }
    }
}

// MARK: - Client

struct ArchiveClient {
    var fetchPhotos: @Sendable (_ lastId: Int?) async throws -> PhotoArchivePageData
    var fetchLetters: @Sendable (_ lastId: Int?) async throws -> LetterArchivePageData
    var fetchMusics: @Sendable (_ lastId: Int?) async throws -> MusicArchivePageData
    var fetchGifts: @Sendable (_ lastId: Int?) async throws -> GiftArchivePageData
}

extension ArchiveClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<ArchiveEndpoint>.build()

        return Self(
            fetchPhotos: {
                try await provider.request(.getPhotos(lastId: $0))
            },
            fetchLetters: {
                try await provider.request(.getLetters(lastId: $0))
            },
            fetchMusics: {
                try await provider.request(.getMusics(lastId: $0))
            },
            fetchGifts: {
                try await provider.request(.getItems(lastId: $0))
            }
        )
    }()

    static let previewValue: Self = {
        Self(
            fetchPhotos: { _ in
                try? await Task.sleep(for: .seconds(1))
                return .mock
            },
            fetchLetters: { _ in .mock },
            fetchMusics: { _ in .mock },
            fetchGifts: { _ in .mock }
        )
    }()
}
