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
    var menuAlignment: Alignment = .top
    var menuAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 12) {
                NetworkImage(url: boxImageUrl)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(spacing: 10) {
                    VStack(spacing: 0) {
                        Text("To. \(receiver)")
                            .packyFont(.body6)
                            .foregroundStyle(.purple500)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(title)
                            .packyFont(.body3)
                            .foregroundStyle(.gray900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text("만든 날짜 \(generatedDate.formattedString(by: .yyyyMdKorean))")
                        .packyFont(.body6)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                menuAction()
            } label: {
                Image(.ellipsis)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(maxHeight: .infinity, alignment: menuAlignment)
        }
        .frame(height: 70)
    }
}

// MARK: - Preview

#Preview {

    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            ForEach(0..<10, id: \.self) { item in
                UnsentBoxCell(
                    boxImageUrl: Constants.mockImageUrl,
                    receiver: "mason",
                    title: "Happy BirthDay!",
                    generatedDate: Date()
                ) {

                }
                .padding(16)
                .background(.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .containerRelativeFrame(.horizontal)
            }
        }
        .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
    .safeAreaPadding(.leading, 24)
    .safeAreaPadding(.trailing, 40)

    // UnsentBoxCell(
    //     boxImageUrl: Constants.mockImageUrl,
    //     receiver: "Mason",
    //     title: "햅삐햅삐 벌쓰데이",
    //     generatedDate: .init()
    // ) {
    //     print("menu")
    // }
    // .bouncyTapGesture {
    //     print("tap")
    // }
    // // .frame(width: 320, height: 100)
    // .border(Color.black)
}
