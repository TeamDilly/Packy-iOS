//
//  LottieAnimation+Extensions.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import Lottie

extension LottieAnimation {
    static func boxAnimation(boxId: Int) -> LottieAnimation? {
        guard let boxMotionName = boxMotionNames[safe: boxId] else { return nil }
        return .named(boxMotionName)
    }
}

private let boxMotionNames: [String] = (1...6).map {
    "Box_motion_\($0)"
}
