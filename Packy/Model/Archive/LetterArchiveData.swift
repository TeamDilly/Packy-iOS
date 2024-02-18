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
            LetterArchiveData(id: 1, letterContent: "이 편지는 영국에서 시작되어...", envelope: Envelope(imgUrl: "https://www.example.com/envelope1.jpg", borderColorCode: "ED76A5", opacity: 30)),
            LetterArchiveData(id: 2, letterContent: "당신에게 전하는 마음을 담았어요...", envelope: Envelope(imgUrl: "https://www.example.com/envelope2.jpg", borderColorCode: "FFD700", opacity: 50))
        ]
    )
}
