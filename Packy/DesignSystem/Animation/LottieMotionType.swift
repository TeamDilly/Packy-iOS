//
//  LottieAnimation+Extensions.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import Foundation

enum LottieMotionType {
    case makeBox(boxDesignId: Int)
    case boxArrived(boxDesignId: Int)

    var motionFileName: String? {
        switch self {
        case let .makeBox(boxId):
            return makeBoxMotionNames[boxId]
        case let .boxArrived(boxId):
            return arrivedBoxMotionNames[boxId]
        }
    }
}

private let makeBoxMotionNames: [Int: String] = (1...6).reduce(into: [Int: String]()) {
    $0[$1] = "Box_motion_make_\($1)"
}

private let arrivedBoxMotionNames: [Int: String] = (1...6).reduce(into: [Int: String]()) {
    $0[$1] = "Box_motion_arr_\($1)"
}
