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
                let response: RecommendedMusicResponse = try await provider.request(.getRecommendedMusics)
                return response.sorted(by: \.sequence)
            },
            fetchProfileImages: {
                let response: ProfileImageResponse = try await nonTokenProvider.request(.getProfileImageDesigns)
                return response.sorted(by: \.sequence)
            },
            fetchLetterDesigns: {
                let response: LetterDesignResponse = try await provider.request(.getEnvelopeDesigns)
                return response.sorted(by: \.sequence)
            },
            fetchBoxDesigns: {
                let response: BoxDesignResponse = try await provider.request(.getBoxDesigns)
                return response.sorted(by: \.sequence)
            },
            fetchStickerDesigns: {
                let response: StickerDesignResponse = try await provider.request(.getStickerDesigns(lastStickerId: $0))
                return response.sorted()
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
                try? await _Concurrency.Task.sleep(for: .seconds(1))
                return .mock
            }
        )
    }()
}
