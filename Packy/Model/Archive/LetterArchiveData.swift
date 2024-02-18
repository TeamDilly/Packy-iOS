//
//  LetterArchiveData.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

struct LetterArchivePageData: Decodable, Hashable {
    let first: Bool
    let last: Bool
    let content: [LetterArchiveData]
}

struct LetterArchiveData: Decodable, Hashable, Identifiable {
    let id: Int
    let letterContent: String
    let envelope: Envelope
}

// MARK: - Mock Data

extension LetterArchivePageData {
    static let mock: Self = .init(
        first: true,
        last: true,
        content: [
            LetterArchiveData(
                id: 1,
                letterContent: "안녕 생일 축하해 어쩌구저쩌구 내 생일은 4월 30일이야 기대할게^^",
                envelope: .mock
            ),
            LetterArchiveData(
                id: 2,
                letterContent: "당신에게 전하는 마음을 담았어요...",
                envelope: .mock
            ),
            LetterArchiveData(
                id: 3,
                letterContent: "안녕 생일 축하해 어쩌구저쩌구 내 생일은 4월 30일이야 기대할게^^",
                envelope: .mock
            ),
            LetterArchiveData(
                id: 4,
                letterContent: "당신에게 전하는 마음을 담았어요...",
                envelope: .mock
            )
        ]
    )
}
