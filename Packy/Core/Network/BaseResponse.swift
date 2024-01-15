//
//  BaseResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let code: String
    let message: String
    let data: T
}

struct EmptyBaseResponse: Decodable {
    let status: String
    let message: String
}

struct ErrorResponse: Error, Decodable {
    let code: String
    let message: String

    static let base = ErrorResponse(code: "000", message: "CannotParse")
}
