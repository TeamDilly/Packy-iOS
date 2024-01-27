//
//  Gift.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

struct Gift: Encodable, Equatable {
    let type: String
    let url: String
}

// MARK: - Mock Data

extension Gift {
    static var mock: Self {
        return Gift(
            type: "photo",
            url: "www.example.com"
        )
    }
}
