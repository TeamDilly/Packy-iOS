//
//  PhotoElement.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct PhotoElement: View {
    var imageURL: URL?
    @Binding var text: String

    private var isPhotoPickable: Bool = false
    private var selectedPhotoData: ((Data?) -> Void)? = nil
    @State private var selectedItem: PhotosPickerItem? = nil

    init(imageURL: URL? = nil, text: Binding<String>) {
        self.imageURL = imageURL
        self._text = text
    }

    var body: some View {
        VStack(spacing: 16) {
            if isPhotoPickable {
                photoPickerView
            } else {
                imageView
            }

            PhotoTextField(text: $text, placeholder: "사진 속 추억을 적어주세요")
                .frame(width: 280, height: 46)
        }
        .padding(16)
        .background(.gray200)
    }
}

// MARK: - Inner Views

private extension PhotoElement {
    var photoPickerView: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            imageView
        }
        .onChange(of: selectedItem) { photoItem in
            Task {
                let data = try? await photoItem?.loadTransferable(type: Data.self)
                selectedPhotoData?(data)
            }
        }
    }

    var imageView: some View {
        KFImage(imageURL)
            .placeholder {
                placeholderView
            }
            .scaleToFillFrame(width: 280, height: 280)
    }

    var placeholderView: some View {
        Color.white
            .overlay {
                Image(.photo)
            }
    }
}

private struct PhotoTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        let prompt = Text(placeholder)
            .foregroundStyle(.gray500)
            .font(.packy(.body5))

        TextField("", text: $text, prompt: prompt)
            .tint(.black)
            .packyFont(.body4)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
}

// MARK: - View Modifiers

extension PhotoElement {
    func photoPickable(selectedPhotoData: @escaping (Data?) -> Void) -> Self {
        var element = self
        element.isPhotoPickable = true
        element.selectedPhotoData = selectedPhotoData
        return element
    }
}

// MARK: - Preview

#Preview {
    VStack {
        PhotoElement(
            imageURL: nil,
            text: .constant("")
        )
        .photoPickable { data in
            print(data)
        }

        PhotoElement(
            imageURL: URL(string: "https://picsum.photos/id/237/200/300"),
            text: .constant("asdada")
        )
    }

}
