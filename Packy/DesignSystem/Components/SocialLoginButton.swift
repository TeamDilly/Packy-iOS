//
//  SocialLoginButton.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

struct SocialLoginButton: View {
    enum LoginType {
        case apple
        case kakao
    }

    let loginType: LoginType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)

                Text(title)
                    .packyFont(.body2)
                    .foregroundStyle(textColor)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Inner Properties

private extension SocialLoginButton {
    // TODO: 아직 상세 디자인 가이드가 안나와서, 차후 변경해야 함
    var logoImage: Image {
        switch loginType {
        case .apple:    return Image(.apple)
        case .kakao:    return Image(.kakao)
        }
    }

    var title: String {
        switch loginType {
        case .apple:    return "Apple로 로그인"
        case .kakao:    return "카카오로 로그인"
        }
    }

    var backgroundColor: Color {
        switch loginType {
        case .apple:    return .black
        case .kakao:    return .init(hex: 0xFEE500)
        }
    }

    var textColor: Color {
        switch loginType {
        case .apple:    return .white
        case .kakao:    return .black
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        SocialLoginButton(loginType: .kakao) {}
        SocialLoginButton(loginType: .apple) {}
    }
    .padding(.horizontal, 24)
}
