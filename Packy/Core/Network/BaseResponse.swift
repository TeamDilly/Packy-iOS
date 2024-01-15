//
//  BaseResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

enum BaseResponse {
    struct SuccessData<ResponseType: Decodable>: Decodable {
        let code: String
        let message: String
        let data: ResponseType
    }

    struct ErrorData: Error, Decodable {
        let code: String
        let message: String

        static let empty = ErrorData(code: "empty", message: "non-compatible server error")
    }
}
