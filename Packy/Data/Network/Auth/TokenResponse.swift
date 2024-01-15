//
//  TokenResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

struct TokenResponse: Decodable {
    let grantType: String
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int64
}
