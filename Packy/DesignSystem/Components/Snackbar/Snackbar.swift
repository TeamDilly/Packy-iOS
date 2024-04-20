//
//  Snackbar.swift
//  Packy
//
//  Created by Mason Kim on 4/20/24.
//

import SwiftUI

struct Snackbar: View {
    let text: String

    var body: some View {
        Text(text)
            .packyFont(.body4)
            .foregroundStyle(.white)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.8))
            )
            .padding(.bottom, 8)
    }
}
