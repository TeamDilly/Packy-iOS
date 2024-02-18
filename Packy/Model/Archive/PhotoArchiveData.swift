//
//  PhotoArchiveData.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

struct PhotoArchivePageData: Decodable, Hashable {
    let first: Bool
    let last: Bool
    let content: [PhotoArchiveData]
}

struct PhotoArchiveData: Decodable, Hashable, Identifiable {
    let id: Int
    let photoUrl: String
    let description: String
}

// MARK: - Mock Data

extension PhotoArchivePageData {
    static let mock: Self = .init(
        first: true,
        last: true,
        content: (0...10).map {
            .init(id: $0, photoUrl: Constants.mockImageUrl, description: "\($0)")
        }
    )
}
