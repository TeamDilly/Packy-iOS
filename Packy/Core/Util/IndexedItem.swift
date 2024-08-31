//
//  IndexedItem.swift
//  Packy
//
//  Created by Mason Kim on 8/31/24.
//

import Foundation

@dynamicMemberLookup
struct IndexedItem<Element>: Identifiable {
    let index: Int
    let element: Element

    subscript<T>(dynamicMember keyPath: WritableKeyPath<Element, T>) -> T {
        return element[keyPath: keyPath]
    }

    var id: Int { index }
}

extension Array {
    func indexedItems(repeatCount: Int = 1) -> [IndexedItem<Element>] {
        let totalCount = count * repeatCount
        return (0..<totalCount).map { index in
            IndexedItem(index: index, element: self[index % count])
        }
    }
}
