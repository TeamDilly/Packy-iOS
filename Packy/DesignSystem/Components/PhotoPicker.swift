//
//  PhotoPicker.swift
//  Packy
//
//  Created by Mason Kim on 1/24/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct PhotoPicker: View {
    var imageURL: URL?
    var selectedPhotoData: ((Data?) -> Void)

    @State private var selectedItem: PhotosPickerItem? = nil

    private var isShowDeleteButton: Bool = false
    private var deleteButtonAction: (() -> Void)? = nil

    init(imageURL: URL? = nil, selectedPhotoData: @escaping (Data?) -> Void) {
        self.imageURL = imageURL
        self.selectedPhotoData = selectedPhotoData
    }

    var body: some View {
        photoPickerView
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.spring, value: imageURL)
    }
}

// MARK: - Inner Functions

private extension PhotoPicker {
    func compressImageData(_ data: Data?) async -> Data? {
        guard let data else { return nil }
        let uiImage = UIImage(data: data)
        let compressedImage = await uiImage?.compressTo(expectedSizeInMB: 1)
        let compressedData = try? compressedImage?.toData()
        return compressedData
    }
}

// MARK: - Inner Views

private extension PhotoPicker {
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
                let loadedData = try? await photoItem?.loadTransferable(type: Data.self)
                let compressedData = await compressImageData(loadedData)
                selectedPhotoData(compressedData)
            }
        }
    }

    var imageView: some View {
        KFImage(imageURL)
            .placeholder {
                placeholderView
            }
            .overlay(alignment: .topTrailing) {
                if isShowDeleteButton {
                    CloseButton(sizeType: .medium, colorType: .dark) {
                        deleteButtonAction?()
                    }
                    .padding(12)
                }
            }
    }

    var placeholderView: some View {
        Color.gray200
            .overlay {
                Image(.photo)
            }
    }
}

// MARK: - View Modifiers

extension PhotoPicker {
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
        PhotoPicker(imageURL: nil) { data in
            print(data)
        }
    }
}
