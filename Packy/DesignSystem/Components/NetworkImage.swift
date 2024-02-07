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
    var useGeometry: Bool = true

    var body: some View {
        GeometryReader { proxy in
            KFImage(URL(string: url))
                .placeholder {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .retry(maxCount: 3, interval: .seconds(1))
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
    }
}

#Preview {
    VStack {
        NetworkImage(url: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/images/c7dd7f0f-76b1-4c07-97c8-c346e5e73769-8BA80892-D8FE-4239-B8D9-24681B1C3393.png")
            .border(Color.red)

        Text("Hello")
            .frame(height: 200)
    }
    .frame(height: 400)
}
