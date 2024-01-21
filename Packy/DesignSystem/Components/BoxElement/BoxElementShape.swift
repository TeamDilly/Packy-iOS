//
//  ElementShape.swift
//  Packy
//
//  Created by Mason Kim on 1/14/24.
//

import Foundation
import SwiftUI

/// 선물 박스 내부의 각 선물 도형 요소
enum BoxElementShape {
    /// 추억 사진 담기
    case photo
    /// 스티커
    case sticker
    /// 편지 쓰기
    case letter
    /// 음악 추가하기
    case music

    func size(fromScreenWidth screenWidth: CGFloat) -> CGSize {
        return .init(width: width(fromScreenWidth: screenWidth), height: height(fromScreenWidth: screenWidth))
    }

    func width(fromScreenWidth screenWidth: CGFloat) -> CGFloat {
        screenWidth * widthRatio
    }

    func height(fromScreenWidth screenWidth: CGFloat) -> CGFloat {
        width(fromScreenWidth: screenWidth) * shapeRatio
    }

    /// 화면 가로 사이즈 대비, 각 요소의 가로 길이 비율
    var widthRatio: CGFloat {
        if UIScreen.main.isWiderThan375pt {
            widthRatioForLargeScreen
        } else {
            widthRatioForSmallScreen
        }
    }

    /// 각 요소의 가로,세로 비율
    var shapeRatio: CGFloat {
        absoluteSize.height / absoluteSize.width
    }

    private var widthRatioForLargeScreen: CGFloat {
        switch self {
        case .photo:    return 0.41
        case .sticker:  return 0.28
        case .letter:   return 0.46
        case .music:    return 0.67
        }
    }

    private var widthRatioForSmallScreen: CGFloat {
        switch self {
        case .photo:    return 0.36
        case .sticker:  return 0.24
        case .letter:   return 0.40
        case .music:    return 0.57
        }
    }

    private var absoluteSize: CGSize {
        switch self {
        case .photo:    return .init(width: 160, height: 192)
        case .sticker:  return .init(width: 110, height: 110)
        case .letter:   return .init(width: 180, height: 150)
        case .music:    return .init(width: 260, height: 146)
        }
    }
}
