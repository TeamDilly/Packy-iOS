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
    var image: Image?
    private var selectedPhotoData: ((PhotoData) -> Void)

    @State private var selectedItem: PhotosPickerItem? = nil

    private var isShowDeleteButton: Bool = false
    private var deleteButtonAction: (() -> Void)? = nil
    private var cropAlignment: Alignment = .center

    init(image: Image? = nil, selectedPhotoData: @escaping (PhotoData) -> Void) {
        self.image = image
        self.selectedPhotoData = selectedPhotoData
    }

    var body: some View {
        photoPickerView
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.spring, value: image)
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
        .onChange(of: selectedItem) { _, photoItem in
            Task {
                let loadedData = try? await photoItem?.loadTransferable(type: Data.self)
                guard let compressedData = await compressImageData(loadedData),
                      let uiImage = UIImage(data: compressedData) else { return }
                let image = Image(uiImage: uiImage)

                await MainActor.run {
                    selectedPhotoData(.init(data: compressedData, image: image))
                }
            }
        }
    }

    var imageView: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            if let image {
                image
                    .resizable()
                    .scaleToFillFrame(width: width, height: width, cropAlignment: cropAlignment)
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
                    .frame(width: width, height: width)
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

    func cropAlignment(_ cropAlignment: Alignment) -> Self {
        var element = self
        element.cropAlignment = cropAlignment
        return element
    }
}

// MARK: - Preview

#Preview {
    VStack {
        PhotoPicker(image: Image(.homeBanner)) { data in
            print(data)
        }
        .aspectRatio(contentMode: .fit)
        .border(Color.black)
        .padding()

        PhotoPicker(image: Image(.homeBanner)) { data in
            print(data)
        }
        .border(Color.black)
        .padding()
    }
    .border(Color.black)
}
