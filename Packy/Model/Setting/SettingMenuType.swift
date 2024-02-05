//
//  SettingMenuType.swift
//  Packy
//
//  Created by Mason Kim on 2/5/24.
//

import Foundation

enum SettingMenuType: String, Decodable, CaseIterable {
    /// 공식 SNS 계정
    case officialSNS = "OFFICIAL_SNS"
    /// 문의하기
    case inquiry = "INQUIRY"
    /// 의견 보내기
    case sendComment = "SEND_COMMENT"
    /// 개인정보 처리방침
    case privacyPolicy = "PRIVACY_POLICY"
    /// 이용 약관
    case termsOfUse = "TERMS_OF_USE"
}

extension SettingMenuType {
    var title: String {
        switch self {
        case .officialSNS:      return "패키 공식 SNS"
        case .inquiry:          return "1:1 문의하기"
        case .sendComment:      return "패키에게 의견 보내기"
        case .privacyPolicy:    return "개인정보처리방침"
        case .termsOfUse:       return "이용약관"
        }
    }
}
