//
//  AppTrackingManager.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import AdSupport
import AppTrackingTransparency

/// AppTrackingTransparency (ATT)
enum ATTManager {
    
    /// ATT 권한 요청
    @MainActor
    static func requestAuthorization() async {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        print("✅ ATT status: \(status), authorized: \(isAuthorized), id: \(advertisingIdentifier?.description ?? "none")")
    }

    /// 맞춤형 광고 제공을 위한 기기 ID (UUID from ATT)
    static var advertisingIdentifier: UUID? {
        guard isAuthorized else { return nil }
        return ASIdentifierManager.shared().advertisingIdentifier
    }

    /// ATT 권한 부여 상태
    static var authorizationStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    static var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
}
