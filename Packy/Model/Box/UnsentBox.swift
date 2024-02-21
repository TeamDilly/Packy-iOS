//
//  UnsentBox.swift
//  Packy
//
//  Created by Mason Kim on 2/21/24.
//

import Foundation

struct UnsentBox: Equatable, Identifiable {
    let id: Int
    let name: String
    let receiverName: String
    let date: Date
    let imageUrl: String
}

// MARK: - Mock Data

extension UnsentBox {
    static let mock: Self = .init(
        id: 0,
        name: "mason",
        receiverName: "moon",
        date: .now,
        imageUrl: Constants.mockImageUrl
    )
}
