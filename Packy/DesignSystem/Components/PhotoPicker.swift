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
    var imageUrl: URL?
    var selectedPhotoData: ((Data?) -> Void)

    @State private var selectedItem: PhotosPickerItem? = nil

    private var isShowDeleteButton: Bool = false
    private var deleteButtonAction: (() -> Void)? = nil

    init(imageUrl: URL? = nil, selectedPhotoData: @escaping (Data?) -> Void) {
        self.imageUrl = imageUrl
        self.selectedPhotoData = selectedPhotoData
    }

    var body: some View {
        photoPickerView
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.spring, value: imageUrl)
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
        GeometryReader { proxy in
            let width = proxy.size.width
            KFImage(imageUrl)
                .placeholder {
                    placeholderView
                }
                .scaleToFillFrame(width: width, height: width)
                .overlay(alignment: .topTrailing) {
                    if isShowDeleteButton {
                        CloseButton(sizeType: .medium, colorType: .dark) {
                            selectedItem = nil
                            deleteButtonAction?()
                        }
                        .padding(12)
                    }
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
        let url = URL(string: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/images/3bea52ca-f174-419f-872c-b0a0b852cdcb-76FE85EC-0AEC-406B-84D8-C2253A83940C.png")!

        PhotoPicker(imageUrl: url) { data in
            print(data)
        }
        .aspectRatio(contentMode: .fit)
        .border(Color.black)
        .padding()

        PhotoPicker(
            imageUrl: URL(string: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/images/3bea52ca-f174-419f-872c-b0a0b852cdcb-76FE85EC-0AEC-406B-84D8-C2253A83940C.png")!
        ) { data in
            print(data)
        }
        .border(Color.black)
        .padding()
    }
    .border(Color.black)
}
