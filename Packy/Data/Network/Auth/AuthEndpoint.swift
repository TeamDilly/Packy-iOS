//
//  AuthEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation
import Moya

enum AuthEndpoint {
    /// 회원가입
    case signUp(authorization: String, request: SignUpRequest)
    /// 로그인
    case signIn(request: SignInRequest)
    /// 회원 탈퇴
    case withdraw
    /// 토큰 재발급
    case reissueToken(request: TokenRequest)
    /// 설정 링크 조회
    case settings
}

extension AuthEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "https://dev.packyforyou.shop/api/v1/")!
    }
    
    var path: String {
        switch self {
        case .signUp:          
            return "auth/sign-up"
        case .reissueToken:          
            return "auth/reissue"
        case .signIn(let request):
            return "auth/sign-in/\(request.provider)"
        case .withdraw:
            return "auth/withdraw"
        case .settings:
            return "admin/settings"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .reissueToken:
            return .post
        case .signIn, .settings:
            return .get
        case .withdraw:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .signUp(_, request):
            return .requestJSONEncodable(request)
        case let .reissueToken(request):
            return .requestJSONEncodable(request)
        case .signIn, .withdraw, .settings:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case let .signUp(authorization, _):
            return ["Authorization": authorization]
        case let .signIn(request):
            return ["Authorization": request.authorization]
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var validationType: ValidationType { .successCodes }
}
