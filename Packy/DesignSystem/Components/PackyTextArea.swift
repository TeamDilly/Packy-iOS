//
//  PackyTextArea.swift
//  Packy
//
//  Created by Mason Kim on 1/9/24.
//

import SwiftUI

struct PackyTextArea: View {
    @Binding var text: String

    let placeholder: String
    var isCompleted: Bool = false
    var borderColor: Color = .gray200
    var showTextLength: Bool = true

    @FocusState var isFocused: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ZStack(alignment: .center) {
                // 회색 위에 border 컬러가 겹쳐지지 않기위해 하얀색 border 깔아줌
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray100)
                    .strokeBorder(.white, lineWidth: 4)

                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(borderColor, lineWidth: 4)

                Text(placeholder)
                    .foregroundStyle(.gray400)
                    .packyFont(.body5)
                    .multilineTextAlignment(.center)
                    .opacity(!isFocused && text.isEmpty ? 1 : 0)

                TextField("", text: $text, axis: .vertical)
                    .tint(.black)
                    .packyFont(.body5)
                    .scrollContentBackground(.hidden)
                    .multilineTextAlignment(.center)
                    .disabled(isCompleted)
                    .focused($isFocused)
                    .zIndex(1)
                    .limitTextLength(text: $text, length: 200)
                    .padding(.horizontal, 20)
            }

            HStack(spacing: 2) {
                Text("\(text.count)")
                Text("/")
                Text("200")
            }
            .opacity(showTextLength ? 1 : 0)
            .packyFont(.body4)
            .foregroundStyle(.gray600)
        }
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    struct SampleView: View {
        @State private var text1 = (1...20).map(String.init).joined(separator: "\n")
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack {
                PackyTextArea(
                    text: $text1,
                    placeholder: "어떤 마음을 담아볼까요?\n따뜻한 인사, 잊지 못할 추억, 고마웠던 순간까지\n모두 좋아요 :)"
                )
                .focused($isFocused)
            }
            .padding()
            .task {
                try? await Task.sleep(for: .seconds(2))
                // isFocused = true
            }
        }
    }

    return SampleView()
}
