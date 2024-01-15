//
//  NetworkLogger.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Alamofire
import Foundation

final class NetworkLogger: EventMonitor {
    let queue: DispatchQueue = DispatchQueue(label: "Network Logger")

    func requestDidFinish(_ request: Request) {
        print("———————————— 📍 Network Request Log 📍 ————————————")
        print("  ✅ [URL] : \(request.request?.url?.absoluteString ?? "")")
        print("  ✅ [Method] : \(request.request?.httpMethod ?? "")")
        print("  ✅ [Headers] : \(request.request?.allHTTPHeaderFields ?? [:])")
        if let body = request.request?.httpBody?.toPrettyPrintedString {
            print("  ✅ [Body]: \(body)")
        }
        print("————————————————————————————————————————————————————")
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        print("———————————— 📍 Network Response Log 📍 ————————————")

        switch response.result {
        case .success:
            print("  ✅ [Status Code] : \(response.response?.statusCode ?? 0)")
        case .failure:
            print("  ❌ 요청에 실패했습니다.")
        }

        if let statusCode = response.response?.statusCode {
            switch statusCode {
            case 400..<500:
                print("  ❌ 클라이언트 오류: statusCode \(statusCode)")
            case 500..<600:
                print("  ❌ 서버 오류: statusCode \(statusCode)")
            default:
                break
            }
        }

        if let response = response.data?.toPrettyPrintedString {
            print("  ✅ [Response] : \(response)")
        }
        print("————————————————————————————————————————————————————")
    }

    func request(_ request: Request, didFailTask task: URLSessionTask, earlyWithError error: AFError) {
        print("  ❌ Did Fail URLSessionTask")
    }

    func request(_ request: Request, didFailToCreateURLRequestWithError error: AFError) {
        print("  ❌ Did Fail To Create URLRequest With Error")
    }

    func requestDidCancel(_ request: Request) {
        print("  ❌ Request Did Cancel")
    }
}


// MARK: - Data Extensions

fileprivate extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else {
            return nil
        }
        return prettyPrintedString as String
    }
}
