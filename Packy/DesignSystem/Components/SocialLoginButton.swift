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
        // TODO: 아직 상세 디자인 가이드가 안나와서, 차후 padding 등 변경해야 함
        Button(action: action) {
            HStack(spacing: 0) {
                logoImage
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(title)
                    .packyFont(.body2)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Inner Properties

private extension SocialLoginButton {
    // TODO: 아직 상세 디자인 가이드가 안나와서, 차후 변경해야 함
    var logoImage: Image {
        switch loginType {
        case .apple:    return Image(.bell)
        case .kakao:    return Image(.bell)
        }
    }

    var title: String {
        switch loginType {
        case .apple:    return "애플 로그인"
        case .kakao:    return "카카오 로그인"
        }
    }

    var backgroundColor: Color {
        switch loginType {
        case .apple:    return .black
        case .kakao:    return .yellow
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
    SocialLoginButton(loginType: .apple) {}
}
