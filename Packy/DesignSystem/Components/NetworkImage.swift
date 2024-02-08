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

    var body: some View {
        KFImage(URL(string: url))
            .placeholder {
                PackyProgress()
            }
            .retry(maxCount: 3, interval: .seconds(1))
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .clipped()
    }
}

#Preview {
    VStack {
        NetworkImage(
            url: Constants.mockImageUrl,
            contentMode: .fit
        )
        .border(Color.red)
        .padding(.horizontal, 50)

        Text("Hello")
        // .frame(height: 200)
    }
    .frame(height: 400)
}
