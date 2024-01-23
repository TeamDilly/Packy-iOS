//
//  HTTPSession.swift
//  Packy
//
//  Created by Mason Kim on 1/23/24.
//

import Foundation
import Alamofire

final class HTTPSession {
    static let shared = HTTPSession()

    private init() {}

    let session: Alamofire.Session = {
        let session = Alamofire.Session(interceptor: TokenInterceptor.shared)
        return session
    }()
}
