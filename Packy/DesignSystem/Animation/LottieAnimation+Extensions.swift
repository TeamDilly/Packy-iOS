//
//  LottieAnimation+Extensions.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import Lottie

extension LottieAnimation {
    static func boxAnimation(boxId: Int) -> LottieAnimation? {
        guard let boxMotionName = boxMotionNames[boxId] else { return nil }
        print("\(boxMotionName), \(boxId)")
        return .named(boxMotionName)
    }
}

private let boxMotionNames: [Int: String] = (1...6).reduce(into: [Int: String]()) {
    $0[$1] = "Box_motion_\($1)"
}
