//
//  KakaoShareClient.swift
//  Packy
//
//  Created Mason Kim on 2/2/24.
//

import Foundation
import Dependencies

import KakaoSDKShare
import KakaoSDKTemplate

// MARK: - Dependency Values

extension DependencyValues {
    // 변수명 소문자로 변경 필요
    var kakaoShare: KakaoShareClient {
        get { self[KakaoShareClient.self] }
        set { self[KakaoShareClient.self] = newValue }
    }
}

// MARK: - KakaoShareClient Client

struct KakaoShareClient {
    var doSomething: @Sendable () async throws -> String
}

extension KakaoShareClient: DependencyKey {
    static let liveValue: Self = {
        Self(
            doSomething: { 
                return "실제 로직"
            }
        )
    }()

    static let testValue: Self = {
        Self(
            doSomething: {  
                return "테스트 로직"
            }
        )
    }()
}


// MARK: - Controller

enum KakaoShareError: Error {
    case emptySendResult
    case invalidUrl
}

struct KakaoShareMessage {
    let title: String
    let description: String
    let link: String
    let imageUrl: String
}

extension KakaoShareMessage {
    init(sender: String, receiver: String, imageUrl: String, link: String) {
        self.title = "\(sender)님이 만든 선물박스가 도착했어요!"
        self.description = "\(receiver)님을 위해 만든 세상에 하나뿐인 선물박스를 열어보세요"
        self.link = link
        self.imageUrl = imageUrl
    }
}

private final class KakaoShareController {
    @MainActor
    func share() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let templateId: Int64 = 0
            let templateArguments = ["title": "제목입니다.", "description": "설명입니다.", "image_url": "https://www.naver.com", "link": "packy open link"]


            if ShareApi.isKakaoTalkSharingAvailable() {
                ShareApi.shared.shareCustom(templateId: templateId, templateArgs: templateArguments) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let result else {
                        continuation.resume(throwing: KakaoShareError.emptySendResult)
                        return
                    }

                    UIApplication.shared.open(result.url)
                    continuation.resume()
                }
            } else {
                guard let url = ShareApi.shared.makeCustomUrl(templateId: templateId, templateArgs: templateArguments) else {
                    continuation.resume(throwing: KakaoShareError.invalidUrl)
                    return
                }

                UIApplication.shared.open(url)
            }
        }
    }
}

