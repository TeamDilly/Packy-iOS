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
            VStack {
                if let photoUrl {
                    NetworkImage(url: photoUrl)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                } else if let image {
                    image
                        .scaleToFillFrame(width: size.width - 16, height: size.width - 16)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                }
            }
            .aspectRatio(1, contentMode: .fit)

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
        PhotoElementView(photoUrl: Constants.mockImageUrl, screenWidth: 300)
            .border(Color.black)
        PhotoElementView(image: Image(.homeBanner), screenWidth: 300)
            .border(Color.black)
    }
}
