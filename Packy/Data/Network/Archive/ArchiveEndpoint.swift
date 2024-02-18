//
//  ArchiveEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation
import Moya

enum ArchiveEndpoint {
    case getPhotos(PhotoArchiveRequest)
}

extension ArchiveEndpoint: TargetType {
    var baseURL: URL {
        Constants.serverUrl
    }

    var path: String {
        switch self {
        case .getPhotos:
            return "gifts/photos"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPhotos:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getPhotos(request):
            let parameters = request.toDictionary()
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
        return nil
    }

    var validationType: ValidationType { .successCodes }
}
