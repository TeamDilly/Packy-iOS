//
//  BoxClient.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
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

// MARK: - boxClient Client

struct BoxClient {
    var makeGiftBox: @Sendable (SendingGiftBox) async throws -> SentGiftBoxInfo
    var openGiftBox: @Sendable (Int) async throws -> ReceivedGiftBox
    var fetchGiftBoxes: @Sendable (GiftBoxesRequest) async throws -> SentReceivedGiftBoxPageData
}

extension BoxClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<BoxEndpoint>.build()
        let nonTokenProvider = MoyaProvider<BoxEndpoint>.buildNonToken()

        return Self(
            makeGiftBox: {
                try await provider.request(.postGiftbox($0))
            },
            openGiftBox: {
                try await provider.request(.getOpenGiftbox($0))
            },
            fetchGiftBoxes: {
                let response: GiftBoxesResponse = try await provider.request(.getGiftBoxes($0))
                return response.toDomian()
            }
        )
    }()

    static var previewValue: Self = {
        Self(
            makeGiftBox: { _ in
                return .init(id: Int.random(in: 0...100), uuid: UUID().uuidString, kakaoMessageImgUrl: nil)
            },
            openGiftBox: { _ in
                return .mock
            },
            fetchGiftBoxes: { _ in
                return .init(giftBoxes: [.mock], isFirstPage: false, isLastPage: false)
            }
        )
    }()
}
