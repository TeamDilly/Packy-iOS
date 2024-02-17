//
//  BottomMenu.swift
//  Packy
//
//  Created by Mason Kim on 2/17/24.
//

import SwiftUI

struct BottomMenu: View {
    let confirmTitle: String
    var cancelTitle: String = "취소"

    let confirmAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack {
            Button {
                confirmAction()
            } label: {
                Text(confirmTitle)
                    .packyFont(.body2)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 60)
            .padding(.top, 8)

            PackyDivider()

            Button {
                cancelAction()
            } label: {
                Text(cancelTitle)
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 60)
            .padding(.bottom, 16)
        }
        .background(.white)
        .clipShape(
            .rect(topLeadingRadius: 16, topTrailingRadius: 16)
        )
    }
}

#Preview {
    VStack {
        Spacer()
        BottomMenu(
            confirmTitle: "삭제하기",
            confirmAction: {

            }, cancelAction: {

            }
        )
        Spacer()
    }
    .background(.gray)
}
