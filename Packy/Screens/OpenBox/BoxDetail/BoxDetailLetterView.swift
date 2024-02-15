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
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ScrollView {
                Text(text)
                    .packyFont(.body4)
                    .multilineTextAlignment(.center)
                    .zIndex(1)
                    .padding(20)
                    .frame(width: width)
                    .frame(minHeight: height)
            }
            .scrollIndicators(.hidden)
            .frame(width: width, height: height - 20)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(borderColor, lineWidth: 4)
        )
        .background(
            // 회색 위에 border 컬러가 겹쳐지지 않기위해 하얀색 border 깔아줌
            RoundedRectangle(cornerRadius: 16)
                .fill(.gray100)
                .strokeBorder(.white, lineWidth: 4)
        )
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    BoxDetailLetterView(text: "편지내용편지내용편지내용편지내용편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n편지내용\n", borderColor: .pink600.opacity(0.3))
        .frame(width: 400, height: 400)
}
