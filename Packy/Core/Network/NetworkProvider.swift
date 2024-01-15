//
//  NetworkProvider.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation
import Alamofire

// MARK: - ApiProvider

struct ApiProvider {

    private let session: Alamofire.Session = {
        let configuration = URLSessionConfiguration.af.default
        let logger = NetworkLogger()
        let interceptor = CustomRequestInterceptor {
            return "token" // TODO: Token read 로직 주입
        }

        return Alamofire.Session(
            configuration: configuration,
            interceptor: interceptor,
            eventMonitors: [logger]
        )
    }()

    func request<T: Decodable>(endPoint: TargetType, type: T.Type) async throws -> T {
        var data: Data?
        switch endPoint.task {
        case .requestMultipartFormData:
            data = try await session.upload(
                multipartFormData: endPoint.multipartFormData,
                with: endPoint
            )
            .validate { _, response, data -> Request.ValidationResult in
                handleResponse(data: data, response, endPoint: endPoint, type: type)
            }
            .serializingData()
            .value

        default:
            data = try await session.request(endPoint)
                .validate { _, response, data -> Request.ValidationResult in
                    handleResponse(data: data, response, endPoint: endPoint, type: type)
                }
                .serializingData()
                .value
        }

        guard let data = data else {
            throw AFError.responseValidationFailed(reason: .dataFileNil)
        }

        let response = try JSONDecoder().decode(BaseResponse.SuccessData<T>.self, from: data)
        return response.data
    }
}

private extension ApiProvider {
    func handleResponse<T: Decodable>(data: Data?, _ response: HTTPURLResponse, endPoint: TargetType, type: T.Type) -> Request.ValidationResult {
        guard let data = data else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }

        guard (200..<300).contains(response.statusCode) else {
            let errorData = try? JSONDecoder().decode(BaseResponse.ErrorData.self, from: data)
            return .failure(AFError.responseValidationFailed(reason: .customValidationFailed(error: errorData ?? .empty)))
        }

        return .success(())
    }
}

// MARK: - RequestInterceptor

fileprivate final class CustomRequestInterceptor: RequestInterceptor {

    var readToken: () -> String?

    init(readToken: @escaping () -> String?) {
        self.readToken = readToken
    }

    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let token = readToken() {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        completion(.success(urlRequest))
    }
}
