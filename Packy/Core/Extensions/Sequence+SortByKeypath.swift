//
//  Sequence+SortByKeypath.swift
//  Packy
//
//  Created by Mason Kim on 1/26/24.
//

import Foundation

enum SortOrder {
    case increasing
    case decreasing
}

extension Sequence {
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        order: SortOrder = .increasing
    ) -> [Self.Element] {
        switch order {
        case .increasing:
            return self.sorted(by: { $0[keyPath: keyPath]  <  $1[keyPath: keyPath] })
        case .decreasing:
            return self.sorted(by: { $0[keyPath: keyPath]  >  $1[keyPath: keyPath] })
        }
    }
}
