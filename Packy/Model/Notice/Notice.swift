//
//  Notice.swift
//  Packy
//
//  Created by Mason Kim on 9/5/24.
//

import Foundation

typealias NoticeResponse = [Notice]

struct Notice: Decodable, Equatable {
    let imgUrl: String?
    let noticeUrl: String?
}

// MARK: - Mock Data

extension [Notice] {
    static let mock: Self = (0...4).map { _ in
        Notice(imgUrl: Constants.mockImageUrl, noticeUrl: "https://www.naver.com")
    }
}
