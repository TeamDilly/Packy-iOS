//
//  ShowErrorView.swift
//  Packy
//
//  Created by Mason Kim on 2/12/24.
//

import SwiftUI

struct ShowErrorView: View {
    let refreshAction: () -> Void
    var message: String = "잠시 후에 다시 시도해주세요"

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("오류가 생겼어요")
                    .packyFont(.heading2)
                    .foregroundStyle(.gray900)

                Text(message)
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
            }

            Button("다시 시도하기") {
                refreshAction()
            }
            .buttonStyle(.box(color: .primary, size: .roundMedium))
        }
    }
}

#Preview {
    ShowErrorView {
        print("refresh")
    }
}
