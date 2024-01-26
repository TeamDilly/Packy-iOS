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
}

// MARK: - Mock

extension ProfileImageResponse {
    static let mock: Self = [
        .init(id: 0, sequence: 0, imageUrl: "https://picsum.photos/200"),
        .init(id: 1, sequence: 1, imageUrl: "https://picsum.photos/300"),
        .init(id: 2, sequence: 2, imageUrl: "https://picsum.photos/250"),
        .init(id: 3, sequence: 3, imageUrl: "https://picsum.photos/350")
    ]
}
