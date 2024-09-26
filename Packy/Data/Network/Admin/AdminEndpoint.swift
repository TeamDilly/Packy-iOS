//
//  AdminEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation
import Moya

enum AdminEndpoint {
    /// 패키 추천 음악 조회
    case getRecommendedMusics
    /// 패키 프로필 이미지 디자인 조회
    case getProfileImageDesigns
    /// 편지지 디자인 조회
    case getEnvelopeDesigns
    /// 박스 디자인 조회
    case getBoxDesigns
    /// 스티커 디자인 조회
    case getStickerDesigns(lastStickerId: Int?, size: Int = 10)
    /// 유튜브 링크 유효성 검사
    case getValidateYoutubeLink(url: String)
    /// 설정 링크 조회
    case settings
    /// 공지사항 목록 조회
    case getNotices
}

extension AdminEndpoint: TargetType {
    var baseURL: URL {
        Constants.serverUrl
    }

    var path: String {
        switch self {
        case .getRecommendedMusics:
            return "v1/admin/music"
        case .getProfileImageDesigns:
            return "v1/admin/design/profiles"
        case .getEnvelopeDesigns:
            return "v1/admin/design/envelopes"
        case .getBoxDesigns:
            return "v1/admin/design/boxes"
        case .getStickerDesigns:
            return "v1/admin/design/stickers"
        case .getValidateYoutubeLink:
            return "v1/admin/youtube"
        case .settings:
            return "v2/admin/settings"
        case .getNotices:
            return "v1/admin/notices"
        }
    }

    var method: Moya.Method {
        switch self {
        default:    
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getStickerDesigns(lastStickerId: lastStickerId, size: size):
            var parameters: [String: Int] = ["size": size]
            if let lastStickerId {
                parameters["lastStickerId"] = lastStickerId
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case let .getValidateYoutubeLink(url: url):
            return .requestParameters(
                parameters: ["url": url],
                encoding: URLEncoding.queryString
            )
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var validationType: ValidationType { .successCodes }
}
