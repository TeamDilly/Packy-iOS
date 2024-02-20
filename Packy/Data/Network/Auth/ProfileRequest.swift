//
//  ProfileRequest.swift
//  Packy
//
//  Created by Mason Kim on 2/20/24.
//

import Foundation

struct ProfileRequest: Encodable {
    let nickname: String?
    let profileImageId: Int?

    enum CodingKeys: String, CodingKey {
        case nickname
        case profileImageId = "profileImg"
    }
}
