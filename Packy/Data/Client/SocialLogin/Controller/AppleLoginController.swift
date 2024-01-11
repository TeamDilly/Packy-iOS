//
//  AppleLoginController.swift
//  Packy
//
//  Created by Mason Kim on 1/8/24.
//

import Foundation
import AuthenticationServices

enum AppleLoginError: LocalizedError {
    case invalidCredential
    case transferError(Error)
}

final class AppleLoginController: NSObject, ASAuthorizationControllerDelegate {

    private var continuation: CheckedContinuation<SocialLoginInfo, Error>?

    func login() async throws -> SocialLoginInfo {
        try await withCheckedThrowingContinuation { continuation in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()

            self.continuation = continuation
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppleLoginError.invalidCredential)
            return
        }

        guard let email = credential.email else {
            // continuation
            return
        }
        print("🍎 appleLogin email \(email)")

        guard let fullName = credential.fullName else {
            // continuation
            return
        }
        print("🍎 appleLogin fullName \(fullName)")

        guard let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            return
        }
        print("🍎 appleLogin token \(token)")

        let userIdentifier = credential.user


        let info = SocialLoginInfo(
            id: userIdentifier,
            token: token,
            name: String(describing: fullName),
            email: email,
            loginType: .apple
        )
        continuation?.resume(returning: info)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
    }
}
