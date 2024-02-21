//
//  ArchiveEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation
import Moya

enum ArchiveEndpoint {
    case getPhotos(lastId: Int?)
    case getMusics(lastId: Int?)
    case getLetters(lastId: Int?)
    /// 선물 모아보기
    case getItems(lastId: Int?)
}

extension ArchiveEndpoint: TargetType {
    var baseURL: URL {
        Constants.serverUrl
    }

    var path: String {
        switch self {
        case .getPhotos:
            return "gifts/photos"
        case .getMusics:
            return "gifts/musics"
        case .getLetters:
            return "gifts/letters"
        case .getItems:
            return "gifts/items"
        }
    }

    var method: Moya.Method { .get }

    var task: Moya.Task {
        switch self {
        case let .getPhotos(lastId):
           return makeTask(key: "last-photo-id", fromId: lastId)
        case let .getMusics(lastId):
            return makeTask(key: "last-giftbox-id", fromId: lastId)
        case let .getLetters(lastId):
            return makeTask(key: "last-letter-id", fromId: lastId)
        case let .getItems(lastId):
            return makeTask(key: "last-giftbox-id", fromId: lastId)
        }
    }

    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }

    var validationType: ValidationType { .successCodes }

    private func makeTask(key: String, fromId id: Int?) -> Moya.Task {
        guard let id else { return .requestPlain }
        return .requestParameters(parameters: [key: id], encoding: URLEncoding.queryString)
    }
}
