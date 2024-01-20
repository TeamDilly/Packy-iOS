//
//  UploadEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import Foundation
import Moya

enum UploadEndpoint {
    /// 파일 업로드를 위한 presigned-url 생성
    case getPreSignedUrl(fileName: String)

    /// 파일 업로드 (확장자명 포함 필요)
    case upload(url: URL, data: Data)
}

extension UploadEndpoint: TargetType {
    var baseURL: URL {
        switch self {
        case .getPreSignedUrl:
            URL(string: "http://packy-dev.ap-northeast-2.elasticbeanstalk.com/api/v1/")!
        case let .upload(url, _):
            url
        }
    }

    var path: String {
        switch self {
        case let .getPreSignedUrl(fileName):
            return "file/presigned-url/\(fileName)"
        case .upload:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPreSignedUrl:
            return .get
        case .upload:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .getPreSignedUrl:
            return .requestPlain
        case let .upload(url: _, data: data):
            return .requestData(data)
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var validationType: ValidationType { .successCodes }
}
