//
//  UploadClient.swift
//  Packy
//
//  Created Mason Kim on 1/20/24.
//

import Foundation
import Dependencies
import Moya

// MARK: - Dependency Values

extension DependencyValues {
    var uploadClient: UploadClient {
        get { self[UploadClient.self] }
        set { self[UploadClient.self] = newValue }
    }
}

enum UploadError: Error {
    case invalidPreSignedURL
}

// MARK: - UploadClient Client

struct UploadClient {
    var upload: @Sendable (UploadRequest) async throws -> UploadResponse
}

extension UploadClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<UploadEndpoint>.build()
        return Self(
            upload: { request in
                let preSignedResponse: PreSignedUrlResponse = try await provider.request(.getPreSignedUrl(fileName: request.fileName))
                guard let preSignedURL = URL(string: preSignedResponse.url) else {
                    throw UploadError.invalidPreSignedURL
                }

                try await provider.requestPlain(.upload(url: preSignedURL, data: request.data))
                return .init(uploadedFileUrl: preSignedURL.trimmedUntilPath)
            }
        )
    }()

    static let previewValue: Self = {
        Self(
            upload: { _ in
                return .init(uploadedFileUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/images/f355c3f0-36ce-40db-9b6e-50d1b5279174-31364E3F-36CD-406C-A39B-1682C0F45062.png")
            }
        )
    }()
}

struct UploadRequest {
    let fileName: String
    let data: Data
}

struct UploadResponse: Decodable {
    let uploadedFileUrl: String
}
