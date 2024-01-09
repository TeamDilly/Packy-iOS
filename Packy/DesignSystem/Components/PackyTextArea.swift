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

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray100)
                    .stroke(.gray200, lineWidth: 4)
                    .frame(width: width, height: width)

                let prompt = Text(placeholder)
                    .foregroundStyle(.gray400)
                    .font(.packy(.body5))

                TextField("", text: $text, prompt: prompt, axis: .vertical)
                    .tint(.black)
                    .packyFont(.body4)
                    .scrollContentBackground(.hidden)
                    .multilineTextAlignment(.center)
                    .disabled(isCompleted)
            }
        }
    }
}

#Preview {
    struct SampleView: View {
        @State private var text1 = ""

        var body: some View {
            VStack {
                PackyTextArea(
                    text: $text1,
                    placeholder: "Placeholder"
                )
            }
            .padding()
        }
    }

    return SampleView()
}
