//
//  TargetType.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Alamofire
import SwiftUI
import UIKit

protocol TargetType: URLRequestConvertible {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var baseURL: URL { get }
}

extension TargetType {
    var headers: [String: String]? {
        switch task {
        case .requestPlain,
                .requestJSONEncodable,
                .requestCustomJSONEncodable,
                .requestJsonBodyParameters,
                .requestUrlQueryParameters,
                .requestCompositeParameters:
            return ["Content-Type": "application/json"]

        case .requestMultipartFormData:
            return ["Content-Type": "multipart/form-data;"]
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = URL(endPoint: self)
        var urlRequest = try URLRequest(url: url, method: httpMethod)
        if let headers = headers {
            urlRequest.headers = HTTPHeaders(headers)
        }
        urlRequest = try addParameter(to: urlRequest)
        return urlRequest
    }

    /// Add `parameters` to `URLRequest` depending on parameters type.
    ///
    /// - Parameters:
    ///   - to:     The `URLRequest` which the `parameters` will be added.
    /// - Returns:  The `URLRequest` which the `parameters` was added.
    private func addParameter(to request: URLRequest) throws -> URLRequest {
        var request = request

        switch task {
        case .requestPlain:
            break
        case let .requestJSONEncodable(parameters):
            request.httpBody = try JSONEncoder().encode(parameters)
        case let .requestCustomJSONEncodable(parameters, encoder):
            request.httpBody = try encoder.encode(parameters)
        case let .requestUrlQueryParameters(parameters):
            request = try EncodingType.queryString.encode(request, with: parameters)
        case let .requestJsonBodyParameters(parameters):
            request = try EncodingType.jsonBody.encode(request, with: parameters)
        case let .requestCompositeParameters(query, body):
            request = try EncodingType.queryString.encode(request, with: query)
            request = try EncodingType.jsonBody.encode(request, with: body)
        case .requestMultipartFormData:
            break
        }
        return request
    }

    var multipartFormData: (MultipartFormData) -> Void {
        if case let .requestMultipartFormData(parameters, uiImages) = task {
            return { formData in
                for (key, value) in parameters {
                    formData.append("\(value)".data(using: .utf8)!, withName: key)
                }

                for (key, uiImage) in uiImages {
                    formData.append(uiImage, withName: key, fileName: "\(key).jpeg", mimeType: "image/jpeg")
                }
            }
        }
        return { _ in }
    }
}


// MARK: - HTTPTask

enum HTTPTask {
    /// 추가 데이터가 없는 요청
    case requestPlain
    /// `Encodable` 를 포함한 요청
    case requestJSONEncodable(Encodable)
    /// `Encodable`, `CustomEncoder` 를 포함한 요청
    case requestCustomJSONEncodable(Encodable, encoder: JSONEncoder)
    /// `get`의 `querystring` 에 사용
    case requestUrlQueryParameters(parameters: Parameters)
    /// `post`의 `body`에 값을 넣을 때 사용
    case requestJsonBodyParameters(parameters: Parameters)
    /// `JsonBody`와 `URLQuery` 매개변수가 결합된 요청 본문 집합
    case requestCompositeParameters(urlParameters: Parameters, bodyParameters: Parameters)
    /// `multipart/form-data` 요청
    case requestMultipartFormData(parameters: Parameters, uIImages: [String: Data])
}


// MARK: - Encoding Type

public enum EncodingType {
    case jsonBody
    case queryString
}

extension EncodingType: ParameterEncoding {
    public func encode(
        _ urlRequest: URLRequestConvertible,
        with parameters: Parameters?
    ) throws -> URLRequest {
        switch self {
        case .jsonBody:
            return try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .queryString:
            return try URLEncoding.queryString.encode(urlRequest, with: parameters)
        }
    }
}


// MARK: - URL Extension

fileprivate extension URL {
    /// Initialize URL from `TargetType`.
    init<T: TargetType>(endPoint: T) {
        let endPointPath = endPoint.path
        if endPointPath.isEmpty {
            self = endPoint.baseURL
        } else {
            self = endPoint.baseURL.appendingPathComponent(endPointPath)
        }
    }
}


// MARK: - URLRequest Extension

extension URLRequest {
    mutating func encoded(encodable: Encodable, encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        do {
            httpBody = try encoder.encode(encodable)

            let contentTypeHeaderName = "Content-Type"
            if value(forHTTPHeaderField: contentTypeHeaderName) == nil {
                setValue("application/json", forHTTPHeaderField: contentTypeHeaderName)
            }

            return self
        } catch {
            throw error
        }
    }
}
