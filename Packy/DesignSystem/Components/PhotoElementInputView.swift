//
//  PhotoElementInputView.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct PhotoElementInputView: View {
    var image: Image?
    @Binding var text: String
    var placeholder: String = "사진 속 추억을 적어주세요"

    private var isPhotoPickable: Bool = false
    private var selectedPhotoData: ((PhotoData) -> Void)? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    
    private var isShowDeleteButton: Bool = false
    private var deleteButtonAction: (() -> Void)? = nil
    
    init(image: Image? = nil, text: Binding<String>) {
        self.image = image
        self._text = text
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if isPhotoPickable {
                photoPickerView
            } else {
                imageView
            }
            
            PhotoTextField(text: $text, placeholder: placeholder)
                .frame(width: 280, height: 46)
        }
        .padding(16)
        .background(.gray200)
        .animation(.spring, value: image)
    }
}

// MARK: - Inner Functions

private extension PhotoElementInputView {
    func compressImageData(_ data: Data?) async -> Data? {
        guard let data else { return nil }
        let uiImage = UIImage(data: data)
        let compressedImage = await uiImage?.compressTo(expectedSizeInMB: 1)
        let compressedData = try? compressedImage?.toData()
        return compressedData
    }
}

// MARK: - Inner Views

private extension PhotoElementInputView {
    var photoPickerView: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            imageView
        }
        .onChange(of: selectedItem) { _, photoItem in
            Task {
                let loadedData = try? await photoItem?.loadTransferable(type: Data.self)
                guard let compressedData = await compressImageData(loadedData),
                      let uiImage = UIImage(data: compressedData) else { return }
                let image = Image(uiImage: uiImage)

                await MainActor.run {
                    selectedPhotoData?(.init(data: compressedData, image: image))
                }
            }
        }
    }
    
    @ViewBuilder
    var imageView: some View {
        if let image {
            image
                .resizable()
                .scaleToFillFrame(width: 280, height: 280)
                .overlay(alignment: .topTrailing) {
                    if isShowDeleteButton {
                        CloseButton(sizeType: .medium, colorType: .dark) {
                            selectedItem = nil
                            deleteButtonAction?()
                        }
                        .padding(12)
                    }
                }
        } else {
            placeholderView
                .frame(width: 280, height: 280)
        }
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
    
    @FocusState private var isFocused: Bool

    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        TextField("", text: $text)
            .tint(.black)
            .packyFont(.body4)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .overlay {
                if isEnabled {
                    Text(placeholder)
                        .foregroundStyle(.gray500)
                        .font(.packy(.body5))
                        .animation(.spring, value: isFocused)
                        .animation(.spring, value: text.isEmpty)
                        .opacity(!isFocused && text.isEmpty ? 1 : 0)
                        .allowsHitTesting(false)
                }
            }
    }
}

// MARK: - View Modifiers

extension PhotoElementInputView {
    func photoPickable(selectedPhotoData: @escaping (PhotoData?) -> Void) -> Self {
        var element = self
        element.isPhotoPickable = true
        element.selectedPhotoData = selectedPhotoData
        return element
    }
    
    func deleteButton(isShown: Bool, action: @escaping () -> Void) -> Self {
        var element = self
        element.isShowDeleteButton = isShown
        element.deleteButtonAction = action
        return element
    }
}

// MARK: - Preview

#Preview {
    VStack {
        PhotoElementInputView(
            image: nil,
            text: .constant("")
        )
        .photoPickable { data in
            print(data.debugDescription)
        }
        
        PhotoElementInputView(
            image: Image(.arrowDown),
            text: .constant("asdada")
        )
        .deleteButton(isShown: true) {
            print("aaa")
        }
    }
}
