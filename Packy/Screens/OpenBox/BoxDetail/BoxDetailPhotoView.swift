//
//  BoxDetailPhotoView.swift
//  Packy
//
//  Created by Mason Kim on 1/30/24.
//

import SwiftUI

struct BoxDetailPhotoView: View {
    var imageUrl: String
    var text: String

    var body: some View {
        PhotoElement(imageUrl: imageUrl, text: .constant(text))
            .disabled(true)
    }
}

#Preview {
    BoxDetailPhotoView(
        imageUrl: "https://picsum.photos/id/237/200/300",
        text: "기억나니 우리의 추억"
    )
}
