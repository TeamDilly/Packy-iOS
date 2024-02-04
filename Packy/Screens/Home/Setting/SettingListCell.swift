//
//  SettingListCell.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import SwiftUI

struct SettingListCell: View {
    var title: String
    var showRightIcon: Bool = true

    var body: some View {
        HStack {
            Text(title)
                .packyFont(.body2)
                .foregroundStyle(.gray900)

            Spacer()

            if showRightIcon {
                Image(.arrowRight)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.gray600)
                    .frame(width: 16, height: 16)
            }
        }
    }
}

#Preview {
    SettingListCell(title: "계정 관리")
}
