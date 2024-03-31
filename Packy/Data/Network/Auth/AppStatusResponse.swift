//
//  AppStatusResponse.swift
//  Packy
//
//  Created by Mason Kim on 3/31/24.
//

import Foundation

struct AppStatusResponse: Decodable {
    let isAvailable: Bool
    let reason: AppStatusInvalidReason?
}

enum AppStatusInvalidReason: String, Decodable {
    case invalidStatus  = "INVALID_STATUS"
    case needUpdate     = "NEED_UPDATE"
}
