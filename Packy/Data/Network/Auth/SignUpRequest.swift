//
//  SignUpRequest.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

struct SignUpRequest: Encodable {
    let provider: SocialLoginProvider
    let nickname: String
    let profileImg: Int
    let pushNotification: Bool
    let marketingAgreement: Bool
}
