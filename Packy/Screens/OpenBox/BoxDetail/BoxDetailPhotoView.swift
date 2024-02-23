//
//  BoxDetailPhotoView.swift
//  Packy
//
//  Created by Mason Kim on 1/30/24.
//

import SwiftUI
import Kingfisher

struct BoxDetailPhotoView: View {
    var imageUrl: String
    var text: String

    var body: some View {
        VStack(spacing: 16) {
            
            KFImage(URL(string: imageUrl))
                .scaleToFillFrame(width: 280, height: 280)

            Text(text)
                .tint(.black)
                .packyFont(.body4)
                .lineLimit(1)
                .frame(width: 280, height: 46)
        }
        .padding(16)
        .background(.gray200)
        .animation(.spring, value: imageUrl)
        .clipped()
    }
}

#Preview {
    BoxDetailPhotoView(
        imageUrl: Constants.mockImageUrl,
        text: "기억나니 우리의 추억"
    )
}
