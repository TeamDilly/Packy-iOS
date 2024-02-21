//
//  BoxClient.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation
import Dependencies
import class Moya.MoyaProvider

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
    var deleteGiftBox: @Sendable (Int) async throws -> Void
    var fetchUnsentBoxes: @Sendable () async throws -> [UnsentBox]
    var changeBoxStatus: @Sendable (Int, BoxSentStatus) async throws -> Void
}

extension BoxClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<BoxEndpoint>.build()

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
            },
            deleteGiftBox: {
                try await provider.requestEmpty(.deleteBox($0))
            },
            fetchUnsentBoxes: {
                let response: UnsentBoxResponse = try await provider.request(.getUnsentBoxes)
                return response.map { $0.toDomain() }
            },
            changeBoxStatus: {
                try await provider.requestEmpty(.changeBoxStats($0, $1))
            }
        )
    }()

    static var previewValue: Self = {
        Self(
            makeGiftBox: { _ in
                try? await Task.sleep(for: .seconds(1))
                return .init(id: Int.random(in: 0...100), uuid: UUID().uuidString, kakaoMessageImgUrl: nil)
            },
            openGiftBox: { _ in
                return .mock
            },
            fetchGiftBoxes: { _ in
                return .init(giftBoxes: [.mock], isFirstPage: true, isLastPage: true)
            },
            deleteGiftBox: { _ in },
            fetchUnsentBoxes: { [] },
            changeBoxStatus: { _, _ in }
        )
    }()
}
