//
//  Array+SafeIndex.swift
//  Packy
//
//  Created by Mason Kim on 1/24/24.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
