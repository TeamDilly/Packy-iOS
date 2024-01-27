//
//  BoxEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation
import Moya

enum BoxEndpoint {
    /// 선물박스 만들기
    case postGiftbox(GiftBox)
}

extension BoxEndpoint: TargetType {
    var baseURL: URL {
        URL(string: "https://dev.packyforyou.shop/api/v1/")!
    }

    var path: String {
        switch self {
        case .postGiftbox:
            return "giftbox"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postGiftbox:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .postGiftbox(giftbox):
            return .requestJSONEncodable(giftbox)
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var validationType: ValidationType { .successCodes }
}
