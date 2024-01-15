//
//  AuthResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

struct AuthResponse: Decodable {
    let grantType: String
    let accessToken: String
    let refreshToken: Int
    let accessTokenExpiresIn: Int
}
