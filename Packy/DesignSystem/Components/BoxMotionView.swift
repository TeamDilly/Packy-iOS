//
//  BoxMotionView.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import SwiftUI
import Lottie

struct BoxMotionView: View {
    let motionType: LottieMotionType

    var body: some View {
        LottieView(
            animation: .named(motionType.motionFileName ?? "")
        )
        .playing()
        .resizable()
        .configure { view in
            view.contentMode = .scaleAspectFill
        }
        .ignoresSafeArea()
    }
}

