//
//  UnsentBoxCell.swift
//  Packy
//
//  Created by Mason Kim on 2/20/24.
//

import SwiftUI

struct UnsentBoxCell: View {
    var boxImageUrl: String
    var receiver: String
    var title: String
    var generatedDate: Date
    var menuAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 12) {
                NetworkImage(url: boxImageUrl)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(spacing: 0) {
                    Text("To. \(receiver)")
                        .packyFont(.body6)
                        .foregroundStyle(.purple500)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(title)
                        .packyFont(.body3)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Text("만든 날짜 \(generatedDate.formattedString(by: .yyyyMdKorean))")
                        .packyFont(.body6)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                Button {
                    menuAction()
                } label: {
                    Image(.ellipsis)
                        .resizable()
                        .frame(width: 24, height: 24)
                }

                Spacer()
            }
        }
        .padding(16)
    }
}

// MARK: - Preview

#Preview {
    UnsentBoxCell(
        boxImageUrl: Constants.mockImageUrl,
        receiver: "Mason",
        title: "햅삐햅삐 벌쓰데이",
        generatedDate: .init()
    ) {
        print("menu")
    }
    .bouncyTapGesture {
        print("tap")
    }
    .frame(width: 320, height: 100)
    .border(Color.black)
}
