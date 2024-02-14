//
//  PhotoElementView.swift
//  Packy
//
//  Created by Mason Kim on 1/29/24.
//

import SwiftUI

struct PhotoElementView: View {
    var photoUrl: String?
    var image: Image?
    let screenWidth: CGFloat
    var action: () -> Void = {}

    init(photoUrl: String, screenWidth: CGFloat, action: @escaping () -> Void = {}) {
        self.photoUrl = photoUrl
        self.screenWidth = screenWidth
        self.action = action
    }

    init(image: Image, screenWidth: CGFloat, action: @escaping () -> Void = {}) {
        self.image = image
        self.screenWidth = screenWidth
        self.action = action
    }

    private let element = BoxElementShape.photo

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)

        VStack {
            if let photoUrl {
                NetworkImage(url: photoUrl)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
            } else if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
                    .clipShape(Rectangle())
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .frame(width: size.width, height: size.height)
        .background(.white)
        .rotationEffect(.degrees(element.rotationDegree))
        .bouncyTapGesture {
            action()
        }
    }
}

#Preview {
    VStack {
        PhotoElementView(photoUrl: Constants.mockImageUrl, screenWidth: 200)
        PhotoElementView(image: Image(.homeBanner), screenWidth: 200)
    }
}
