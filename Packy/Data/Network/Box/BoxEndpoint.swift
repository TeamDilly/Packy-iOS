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
    case postGiftbox(SendingGiftBox)
    /// 선물박스 열기
    case getOpenGiftbox(Int)
    /// 주고받은 선물박스 조회
    case getGiftBoxes(GiftBoxesRequest)
    /// 선물박스 삭제
    case deleteBox(Int)
}

extension BoxEndpoint: TargetType {
    var baseURL: URL {
        Constants.serverUrl
    }

    var path: String {
        switch self {
        case .getGiftBoxes, .postGiftbox:
            return "giftboxes"
        case let .getOpenGiftbox(boxId):
            return "giftboxes/\(boxId)"
        case let .deleteBox(boxId):
            return "giftboxes/\(boxId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postGiftbox:
            return .post
        case .getOpenGiftbox, .getGiftBoxes:
            return .get
        case .deleteBox:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .postGiftbox(giftbox):
            return .requestJSONEncodable(giftbox)
        case let .getGiftBoxes(request):
            let parameters = request.toDictionary()
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var validationType: ValidationType { .successCodes }
}
