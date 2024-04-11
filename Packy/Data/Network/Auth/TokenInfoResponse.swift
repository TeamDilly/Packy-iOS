//
//  TokenInfoResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

struct TokenInfoResponse: Decodable {
    let id: Int?
    let grantType: String?
    let accessToken: String?
    let refreshToken: String?
    let accessTokenExpiresIn: Int?
}

extension TokenInfoResponse {
    static let mock: TokenInfoResponse = .init(id: 0, grantType: "", accessToken: "", refreshToken: "", accessTokenExpiresIn: 0)
}
