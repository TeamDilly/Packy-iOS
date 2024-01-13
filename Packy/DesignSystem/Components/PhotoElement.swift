//
//  PhotoElement.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import Kingfisher

struct PhotoElement: View {
    var imageURL: URL?
    @Binding var text: String

    var isPrimaryPhoto: Bool = true
    var imageTapAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Button {
                imageTapAction?()
            } label: {
                KFImage(imageURL)
                    .placeholder {
                        Color.gray200
                            .overlay {
                                Image(.plus)
                            }
                    }
                    .scaleToFillFrame(width: 280, height: 280)
            }
            .buttonStyle(.bouncy)
            .disabled(imageURL != nil) 

            PhotoTextField(text: $text, placeholder: "사진 속 추억을 적어주세요")
                .frame(width: 280, height: 46)
        }
        .padding(16)
        .background(.gray100)
    }
}

extension PhotoElement {
    func imageTapAction(action: @escaping () -> Void) -> Self {
        var element = self
        element.imageTapAction = action
        return element
    }
}

private struct PhotoTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        let prompt = Text(placeholder)
            .foregroundStyle(.gray400)
            .font(.packy(.body5))

        TextField("", text: $text, prompt: prompt)
            .tint(.black)
            .packyFont(.body4)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    VStack {
        PhotoElement(
            imageURL: nil,
            text: .constant("")
        )
        .imageTapAction { }

        PhotoElement(
            imageURL: URL(string: "https://picsum.photos/id/237/200/300"),
            text: .constant("asdada")
        )
    }

}
