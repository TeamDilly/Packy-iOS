//
//  HTTPSession.swift
//  Packy
//
//  Created by Mason Kim on 1/23/24.
//

import Foundation
import Moya

final class HTTPSession {
    static let shared = HTTPSession()

    private init() {}

    let session: Moya.Session = {
        let session = Moya.Session(interceptor: TokenInterceptor.shared)
        return session
    }()
}
