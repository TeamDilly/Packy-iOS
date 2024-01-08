//
//  APIKey.swift
//  Packy
//
//  Created by Mason Kim on 1/8/24.
//

import Foundation

enum APIKey {
    static let kakao = {
        guard let infoDictionary = Bundle.main.infoDictionary else { fatalError("Wrong Info dictionary") }
        guard let key = infoDictionary["KAKAO_API_KEY"] as? String else { fatalError("Wrong API Key") }
        return key
    }()
}
