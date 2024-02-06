//
//  OnboardingPage.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

enum OnboardingPage: Int, CaseIterable {
    case one
    case two

    var title: String {
        switch self {
        case .one:      return "패키와 함께 특별한\n선물박스를 만들어보세요"
        case .two:      return "패키의 선물박스로\n주고받은 마음을 추억해요"
        }
    }

    var image: Image {
        switch self {
        case .one:      return Image(.onboardingImg1)
        case .two:      return Image(.onboardingImg2)
        }
    }

    var buttonTitle: String {
        if self == OnboardingPage.allCases.last {
            return "시작하기"
        }

        return "다음"
    }
}
