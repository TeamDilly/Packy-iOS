//
//  NetworkImage.swift
//  Packy
//
//  Created by Mason Kim on 1/26/24.
//

import Kingfisher
import SwiftUI

struct NetworkImage: View {
    var url: String
    var contentMode: SwiftUI.ContentMode = .fill
    var respectPhotoSize: Bool = false
    var cropAlignment: Alignment = .center

    var body: some View {
        if respectPhotoSize {
            KFImage(URL(string: url))
                .placeholder {
                    PackyProgress()
                }
                .retry(maxCount: 3, interval: .seconds(1))
                .aspectRatio(contentMode: contentMode)
        } else {
            GeometryReader { proxy in
                KFImage(URL(string: url))
                    .placeholder {
                        PackyProgress()
                    }
                    .retry(maxCount: 3, interval: .seconds(1))
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: cropAlignment)
                    .clipped()
            }
        }
    }
}

#Preview {
    VStack {
        NetworkImage(
            url: Constants.mockImageUrl,
            contentMode: .fit
        )
        .border(Color.red)
        .padding(.horizontal, 10)
        .frame(width: 50, height: 50)

        Text("Hello")
            // .frame(height: 200)
    }
    .frame(height: 400)
}
