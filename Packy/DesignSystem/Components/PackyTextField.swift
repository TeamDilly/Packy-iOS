//
//  PackyTextField.swift
//  Packy
//
//  Created by Mason Kim on 1/9/24.
//

import SwiftUI

struct PackyTextField: View {
    @Binding var text: String

    let placeholder: String
    var label: String? = nil
    var errorMessage: String? = nil
    var isCompleted: Bool = false

    @FocusState private var textFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label {
                Text(label)
                    .packyFont(.body4)
                    .foregroundStyle(.gray800)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.gray100)
                    .frame(height: 50)

                HStack(spacing: 0) {
                    textField
                        .padding(.vertical, 14)
                        .padding(.leading, 16)
                        .frame(height: 50)
                        // .border(Color.black)

                    Spacer()
                    if !text.isEmpty && !isCompleted {
                        Button {
                            text = ""
                            textFieldFocused = true
                        } label: {
                            Image(.xmarkCircleFill)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        // .border(Color.black)
                        .padding(.vertical, 13)
                        .padding(.trailing, 12)
                        // .border(Color.black)
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .packyFont(.body6)
                    .foregroundStyle(Color(hex: 0xF34248))
            }
        }
        .onTapGesture {
            textFieldFocused = true
        }
    }

    private var textField: some View {
        let prompt = Text(placeholder)
            .foregroundStyle(.gray400)
            .font(.packy(.body4))

        // 텍스트필드
        return TextField("", text: $text, prompt: prompt)
            .tint(.black)  // 커서 색상
            .packyFont(.body4)
            .disabled(isCompleted)
            .focused($textFieldFocused)
            .truncationMode(.head)
    }
}


#Preview {
    struct SampleView: View {
        @State private var text1 = "hello"
        @State private var text2 = "what's up"
        var body: some View {
            VStack {
                PackyTextField(
                    text: $text1,
                    placeholder: "Placeholder",
                    label: "Label",
                    errorMessage: "Error Message..."
                )

                PackyTextField(
                    text: $text2,
                    placeholder: "Placeholder",
                    label: "Label",
                    isCompleted: true
                )
            }
            .padding()
        }
    }

    return SampleView()
}
