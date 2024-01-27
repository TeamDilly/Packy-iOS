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
    var fetchStickerDesigns: @Sendable (_ lastStickerId: Int) async throws -> StickerDesignResponse
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
                try await provider.request(.getStickerDesigns(lastStickerId: $0))
            }
        )
    }()

    static var previewValue: Self = {
        Self(
            fetchRecommendedMusics: { .mock },
            fetchProfileImages: { .mock },
            fetchLetterDesigns: { .mock },
            fetchBoxDesigns: { .mock },
            fetchStickerDesigns: { _ in
                try? await _Concurrency.Task.sleep(for: .seconds(2))
                return .mock
            }
        )
    }()
}
