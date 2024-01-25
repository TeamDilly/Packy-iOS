//
//  BoxClient.swift
//  Packy
//
//  Created Mason Kim on 1/21/24.
//

import Foundation
import Dependencies
import Moya

// MARK: - Dependency Values

extension DependencyValues {
    var boxClient: BoxClient {
        get { self[BoxClient.self] }
        set { self[BoxClient.self] = newValue }
    }
}

// MARK: - BoxClient Client

struct BoxClient {
    var fetchRecommendedMusics: @Sendable () async throws -> RecommendedMusicResponse
    var fetchProfileImages: @Sendable () async throws -> ProfileImageResponse
    var fetchLetterDesigns: @Sendable () async throws -> LetterDesignResponse
    var fetchBoxDesigns: @Sendable () async throws -> BoxDesignResponse
    var fetchStickerDesigns: @Sendable () async throws -> [StickerDesign]
}

extension BoxClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<BoxEndpoint>.build()
        return Self(
            fetchRecommendedMusics: {
                try await provider.request(.getRecommendedMusics)
            },
            fetchProfileImages: {
                try await provider.request(.getProfileImageDesigns)
            },
            fetchLetterDesigns: {
                try await provider.request(.getLetterDesigns)
            },
            fetchBoxDesigns: {
                try await provider.request(.getBoxDesigns)
            },
            fetchStickerDesigns: {
                let response: StickerDesignResponse = try await provider.request(.getStickerDesigns)
                return response.contents.sorted(by: \.sequence)
            }
        )
    }()

    static var previewValue: Self = {
        Self(
            fetchRecommendedMusics: { .mock },
            fetchProfileImages: { .mock },
            fetchLetterDesigns: { .mock },
            fetchBoxDesigns: { .mock },
            fetchStickerDesigns: { .mock }
        )
    }()
}
