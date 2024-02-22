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
    /// 보내지 않은 선물박스 조회
    case getUnsentBoxes
    /// 선물박스 전송 상태 변경
    case changeBoxStats(Int, BoxSentStatus)
    /// 박스 공유용 카카오톡 이미지 조회
    case getKakaoImage(Int)
    /// 화면에서 팝업 형태로 띄워줄 선물박스 조회
    case getPopupGiftbox(ScreenType)
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
        case .getUnsentBoxes:
            return "giftboxes/waiting"
        case let .changeBoxStats(boxId, _):
            return "giftboxes/\(boxId)"
        case let .getKakaoImage(boxId):
            return "giftboxes/\(boxId)/kakao-image"
        case let .getPopupGiftbox(screenType):
            return "giftboxes/\(screenType.rawValue)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postGiftbox:
            return .post
        case .getOpenGiftbox, .getGiftBoxes, .getUnsentBoxes, .getKakaoImage, .getPopupGiftbox:
            return .get
        case .deleteBox:
            return .delete
        case .changeBoxStats:
            return .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case let .postGiftbox(giftbox):
            return .requestJSONEncodable(giftbox)

        case let .getGiftBoxes(request):
            let parameters = request.toDictionary()
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )

        case let .changeBoxStats(_, status):
            return .requestParameters(
                parameters: ["deliverStatus": status.rawValue],
                encoding: JSONEncoding.default
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
