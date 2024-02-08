//
//  BoxDetailLetterView.swift
//  Packy
//
//  Created by Mason Kim on 1/30/24.
//

import SwiftUI

struct BoxDetailLetterView: View {
    var text: String
    var borderColor: Color

    var body: some View {
        PackyTextArea(
            text: .constant(text),
            placeholder: "",
            borderColor: borderColor,
            showTextLength: false
        )
        .aspectRatio(1, contentMode: .fit)
        .disabled(true)
    }
}

#Preview {
    BoxDetailLetterView(text: "편지내용", borderColor: .pink100)
}
