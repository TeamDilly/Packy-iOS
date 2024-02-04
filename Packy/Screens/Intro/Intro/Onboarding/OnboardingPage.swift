//
//  OnboardingPage.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

enum OnboardingPage: Int, CaseIterable {
    case makeBox
    case rememberEvent

    var title: String {
        switch self {
        case .makeBox:
            return "패키와 함께 특별한 선물박스를 만들어보세요"
        case .rememberEvent:
            return "다가오는 이벤트를 기다리고 지나간 이벤트를 추억해요"
        }
    }

    var image: Image {
        switch self {
        case .makeBox:          return Image(.packyLogoPurple)
        case .rememberEvent:    return Image(.packyLogoPurple)
        }
    }

    var buttonTitle: String {
        if self == OnboardingPage.allCases.last {
            return "시작하기"
        }

        return "다음"
    }
}
