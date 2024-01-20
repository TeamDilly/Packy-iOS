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

    @FocusState var isFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray100)
                    .stroke(.gray200, lineWidth: 4)
                    .frame(width: width, height: width)

                Text(placeholder)
                    .foregroundStyle(.gray400)
                    .font(.packy(.body5))
                    .multilineTextAlignment(.center)
                    .opacity(!isFocused && text.isEmpty ? 1 : 0)

                TextField("", text: $text, axis: .vertical)
                    .tint(.black)
                    .packyFont(.body4)
                    .scrollContentBackground(.hidden)
                    .multilineTextAlignment(.center)
                    .disabled(isCompleted)
                    .focused($isFocused)
                    .zIndex(1)
            }
        }
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    struct SampleView: View {
        @State private var text1 = ""
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
                isFocused = true
            }
        }
    }

    return SampleView()
}
