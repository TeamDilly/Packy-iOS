//
//  MoyaLoggerPlugin.swift
//  Packy
//
//  Created by Mason Kim on 1/16/24.
//

import Foundation
import Moya

struct MoyaLoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("[HTTP Request] invalid request")
            return
        }

        print("———————————— 🚀 Network Request Log 🚀 ————————————")

        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"
        print("  ✅ [URL] : \(url)")
        print("  ✅ [TARGET] : \(target)")
        print("  ✅ [Method] : \(method)")

        if let headers = httpRequest.allHTTPHeaderFields {
            print("  ✅ [Headers] : \(headers)")
        }

        if let body = httpRequest.httpBody {
            print("  ✅ [Body] : \(prettyPrintJSON(body))")
        }

        logEndSeparator()
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }

    func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
        print("———————————— ✅ Network Response Log ✅ ————————————")

        let url = response.request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        print("  ✅ [URL] : \(url)")
        print("  ✅ [TARGET] : (target)")
        print(" ✅ [Status Code] : (statusCode)")
        if let headers = response.response?.allHeaderFields {
            print("  ✅ [Headers] : \(headers)")
        }

        print("  ✅ [Response] : \(prettyPrintJSON(response.data))")

        logEndSeparator()
    }

    func onFail(_ error: MoyaError, target: TargetType) {
        print("———————————— ❌ Network Error Log ❌ ————————————")

        print("  ❌ [TARGET] : \(target)")
        print("  ❌ [ErrorCode] : \(error.errorCode)")

        if let errorMessage = error.failureReason ?? error.errorDescription {
            print("  ❌ [Message] : \(errorMessage)")
        }

        if let response = error.response {
            print("  ❌ [Response] : \(prettyPrintJSON(response.data))")
        }

        logEndSeparator()
    }
}

private extension MoyaLoggerPlugin {
    func logEndSeparator() {
        print("————————————————————————————————————————————————————")
    }

    func prettyPrintJSON(_ data: Data) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let prettyPrintedString = String(data: prettyData, encoding: .utf8) {
            return prettyPrintedString
        } else {
            return String(decoding: data, as: UTF8.self)
        }
    }
}
