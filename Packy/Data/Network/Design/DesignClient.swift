//
//  designClient.swift
//  Packy
//
//  Created Mason Kim on 1/21/24.
//

import Foundation
import Dependencies
import Moya

// MARK: - Dependency Values

extension DependencyValues {
    var designClient: DesignClient {
        get { self[DesignClient.self] }
        set { self[DesignClient.self] = newValue }
    }
}

// MARK: - designClient Client

struct DesignClient {
    var fetchRecommendedMusics: @Sendable () async throws -> RecommendedMusicResponse
    var fetchProfileImages: @Sendable () async throws -> ProfileImageResponse
    var fetchLetterDesigns: @Sendable () async throws -> LetterDesignResponse
    var fetchBoxDesigns: @Sendable () async throws -> BoxDesignResponse
    var fetchStickerDesigns: @Sendable () async throws -> [StickerDesign]
}

extension DesignClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<DesignEndpoint>.build()
        let nonTokenProvider = MoyaProvider<DesignEndpoint>.buildNonToken()

        return Self(
            fetchRecommendedMusics: {
                try await provider.request(.getRecommendedMusics)
            },
            fetchProfileImages: {
                try await nonTokenProvider.request(.getProfileImageDesigns)
            },
            fetchLetterDesigns: {
                try await provider.request(.getEnvelopeDesigns)
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
