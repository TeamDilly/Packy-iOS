//
//  Checkbox.swift
//  Packy
//
//  Created by Mason Kim on 1/9/24.
//

import SwiftUI

struct Checkbox: View {
    var isChecked: Bool
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            Image(.check)
                .renderingMode(.template)
                .foregroundStyle(isChecked ? .purple500 : .gray400)
                .animation(.spring, value: isChecked)

            Text(label)
                .packyFont(.body3)
                .foregroundStyle(.gray800)
        }
    }
}

#Preview {
    VStack {
        Checkbox(isChecked: true, label: "체크")
        Checkbox(isChecked: false, label: "해제")
    }
}
