//
//  TokenRequest.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

struct TokenRequest: Encodable {
    let accessToken: String
    let refreshToken: String
}
