//
//  SocialLoginButton.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

struct SocialLoginButton: View {
    let loginType: SocialLoginProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(loginType.imageResource)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)

                Text("\(loginType.description)로 로그인")
                    .packyFont(.body2)
                    .foregroundStyle(textColor)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(loginType.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Inner Properties

private extension SocialLoginButton {
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
