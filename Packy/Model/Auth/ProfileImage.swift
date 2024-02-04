//
//  ProfileImage.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation

typealias ProfileImageResponse = [ProfileImage]

struct ProfileImage: Decodable, Equatable {
    let id: Int
    let sequence: Int
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case sequence
        case imageUrl = "imgUrl"
    }
}

// MARK: - Mock

extension ProfileImageResponse {
    static let mock: Self = (0...3).map {
        .init(id: $0, sequence: $0, imageUrl: Constants.mockImageUrl)
    }
}
