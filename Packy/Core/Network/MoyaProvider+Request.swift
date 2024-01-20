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
                        print("✅ \(result.statusCode) \(String(data: result.data, encoding: .utf8)), \(result.description)")
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: result.data)
                        continuation.resume(throwing: errorResponse ?? .base)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
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
                    continuation.resume(throwing: error)
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
