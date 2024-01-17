//
//  Encodable+ToDictionary.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any] {
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(self)

            let dictionaryData = try JSONSerialization.jsonObject(
                with: encodedData,
                options: .allowFragments
            ) as? [String: Any]
            return dictionaryData ?? [:]
        } catch {
            return [:]
        }
    }
}
