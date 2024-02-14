//
//  Photo.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

struct Photo: Codable, Equatable {
    var photoUrl: String
    let description: String
    let sequence: Int
}

struct PhotoRawData: Equatable {
    let photoData: Data?
    let description: String
    let sequence: Int
}

// MARK: - Mock Data

extension PhotoRawData {
    static var mock: Self {
        return .init(
            photoData: nil,
            description: "우리 같이 놀러갔던 날 :)",
            sequence: 1
        )
    }
}

extension Photo {
    static var mock: Self {
        return .init(
            photoUrl: Constants.mockImageUrl,
            description: "우리 같이 놀러갔던 날 :)",
            sequence: 1
        )
    }
}
