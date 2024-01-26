//
//  MoyaProvider+Build.swift
//  Packy
//
//  Created by Mason Kim on 1/23/24.
//

import Moya

extension MoyaProvider {
    /// Logger, Interceptor 를 주입한 Provider 를 생성함
    static func build() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(
            session: HTTPSession.shared.session,
            plugins: [MoyaLoggerPlugin()]
        )
    }

    /// 토큰 Interceptor를 제외한 Provider 를 생성함
    static func buildNonToken() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(
            session: Moya.Session(),
            plugins: [MoyaLoggerPlugin()]
        )
    }
}
