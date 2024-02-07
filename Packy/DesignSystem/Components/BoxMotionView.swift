//
//  BoxMotionView.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import SwiftUI
import Lottie

struct BoxMotionView: View {
    let boxId: Int
    var body: some View {
        LottieView(
            animation: .boxAnimation(boxId: boxId)
        )
        .playing()
        .resizable()
        .configure { view in
            view.contentMode = .scaleAspectFill
        }
        .ignoresSafeArea()
    }
}

