//
//  BoxEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation
import Moya

enum BoxEndpoint {
    /// 패키 추천 음악 조회
    case getRecommendedMusics
    /// 패키 프로필 이미지 디자인 조회
    case getProfileImageDesigns
    /// 편지지 디자인 조회
    case getLetterDesigns
    /// 박스 디자인 조회
    case getBoxDesigns
    /// 스티커 디자인 조회
    case getStickerDesigns
}

extension BoxEndpoint: TargetType {
    var baseURL: URL {
        URL(string: "https://dev.packyforyou.shop/api/v1/")!
    }

    var path: String {
        switch self {
        case .getRecommendedMusics:
            return "admin/music"
        case .getProfileImageDesigns:
            return "admin/design/profiles"
        case .getLetterDesigns:
            return "admin/design/letters"
        case .getBoxDesigns:
            return "admin/design/boxes"
        case .getStickerDesigns:
            return "admin/design/stickers"
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
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var validationType: ValidationType { .successCodes }
}
