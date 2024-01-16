//
//  SignInResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/16/24.
//

import Foundation

struct SignInResponse: Decodable {
    let status: SignInStatus
    let tokenInfo: TokenInfoResponse?
}

enum SignInStatus: String, Decodable {
    case registered     = "REGISTERED"
    case notRegistered  = "NOT_REGISTERED"
}

extension SignInResponse {
    static let mock: SignInResponse = .init(status: .registered, tokenInfo: .mock)
}
