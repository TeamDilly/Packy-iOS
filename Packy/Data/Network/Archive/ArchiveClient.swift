//
//  ArchiveClient.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation
import Dependencies
import Moya

// MARK: - Dependency Values

extension DependencyValues {
    var archiveClient: ArchiveClient {
        get { self[ArchiveClient.self] }
        set { self[ArchiveClient.self] = newValue }
    }
}

// MARK: - Client

struct ArchiveClient {
    var fetchPhotos: @Sendable (PhotoArchiveRequest) async throws -> PhotoArchivePageData
}

extension ArchiveClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<ArchiveEndpoint>.build()

        return Self(
            fetchPhotos: {
                try await provider.request(.getPhotos($0))
            }
        )
    }()

    static let previewValue: Self = {
        Self(
            fetchPhotos: { _ in .mock }
        )
    }()
}
