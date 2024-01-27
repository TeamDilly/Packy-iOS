//
//  Terms.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import Foundation

enum Terms: CaseIterable {
    case termsOfService
    case personalInfo
    case eventAndMarketing

    var title: String {
        switch self {
        case .termsOfService:     return "(필수) 서비스 이용약관"
        case .personalInfo:       return "(필수) 개인정보 수집 및 이용안내"
        case .eventAndMarketing:  return "(선택) 이벤트 및 마케팅 수신 동의"
        }
    }

    var isRequired: Bool {
        switch self {
        case .termsOfService:     return true
        case .personalInfo:       return true
        case .eventAndMarketing:  return false
        }
    }
}
