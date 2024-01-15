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
