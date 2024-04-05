//
//  AuthEndpoint.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation
import Moya

enum AuthEndpoint {
    /// 앱 사용 가능 상태 확인
    case checkStatus
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
    /// 나의 프로필 조회
    case profile
    /// 나의 프로필 수정
    case editProfile(ProfileRequest)
}

extension AuthEndpoint: TargetType {
    var baseURL: URL {
        Constants.serverUrl
    }
    
    var path: String {
        switch self {
        case .checkStatus:
            return "member/status"
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
        case .profile, .editProfile:
            return "my-page/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .reissueToken:
            return .post
        case .signIn, .settings, .profile, .checkStatus:
            return .get
        case .withdraw:
            return .delete
        case .editProfile:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .checkStatus:
            return .requestParameters(
                parameters: ["app-version": Constants.appVersion],
                encoding: URLEncoding.queryString
            )
        case let .signUp(_, request):
            return .requestJSONEncodable(request)
        case let .reissueToken(request):
            return .requestJSONEncodable(request)
        case let .editProfile(request):
            return .requestJSONEncodable(request)
        default:
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
