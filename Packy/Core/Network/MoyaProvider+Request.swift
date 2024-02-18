//
//  MoyaProvider+Request.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation
import Moya

extension MoyaProvider {
    func request<T: Decodable>(_ target: Target) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { response in
                switch response {
                case .success(let result):
                    do {
                        let networkResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: result.data)
                        continuation.resume(returning: networkResponse.data)
                    } catch {
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: result.data)
                        continuation.resume(throwing: errorResponse ?? .base)
                    }

                case .failure(let error):
                    if let response = error.response?.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response)
                        continuation.resume(throwing: errorResponse ?? .base)
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    func requestEmpty(_ target: Target) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { response in
                switch response {
                case .success(let result):
                    do {
                        let networkResponse = try JSONDecoder().decode(EmptyBaseResponse.self, from: result.data)
                        continuation.resume(returning: networkResponse.status)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    if let response = error.response?.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response)
                        continuation.resume(throwing: errorResponse ?? .base)
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    func requestPlain(_ target: Target) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { response in
                switch response {
                case .success:
                    continuation.resume()

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
