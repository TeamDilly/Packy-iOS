//
//  PhotoElementView.swift
//  Packy
//
//  Created by Mason Kim on 1/29/24.
//

import SwiftUI

struct PhotoElementView: View {
    let photoUrl: String
    let screenWidth: CGFloat
    var action: () -> Void = {}

    private let element = BoxElementShape.photo

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)

        VStack {
            NetworkImage(url: photoUrl)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 8)
                .padding(.top, 8)

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
    PhotoElementView.init(photoUrl: Constants.mockImageUrl, screenWidth: 200)
}
