//
//  ProfileRequest.swift
//  Packy
//
//  Created by Mason Kim on 2/20/24.
//

import Foundation

struct ProfileRequest: Encodable {
    let nickname: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case nickname
        case profileImage = "profileImg"
    }
}
