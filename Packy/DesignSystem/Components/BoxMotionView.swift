//
//  BoxMotionView.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import SwiftUI
import Lottie

struct BoxMotionView: View {
    let boxDesignId: Int
    var body: some View {
        LottieView(
            animation: .boxAnimation(boxId: boxDesignId)
        )
        .playing()
        .resizable()
        .configure { view in
            view.contentMode = .scaleAspectFill
        }
        .ignoresSafeArea()
    }
}

