//
//  ElementShape.swift
//  Packy
//
//  Created by Mason Kim on 1/14/24.
//

import Foundation

/// 선물 박스 내부의 각 선물 도형 요소
enum BoxElementShape {
    case musicCircle
    case letterRectangle
    case photoRectangle
    case giftEllipse

    var absoluteSize: CGSize {
        switch self {
        case .musicCircle:      return .init(width: 210, height: 210)
        case .letterRectangle:  return .init(width: 163, height: 228)
        case .photoRectangle:   return .init(width: 163, height: 202)
        case .giftEllipse:      return .init(width: 163, height: 189)
        }
    }

    var shapeRatio: CGFloat {
        absoluteSize.height / absoluteSize.width
    }

    func relativeSize(geometryWidth: CGFloat) -> CGSize {
        let standardWidth: CGFloat = 390
        let widthRatio = absoluteSize.width / standardWidth
        let width = geometryWidth * widthRatio
        let height = width * shapeRatio
        return .init(width: width, height: height)
    }
}
