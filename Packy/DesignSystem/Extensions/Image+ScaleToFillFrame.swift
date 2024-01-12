//
//  Image+ScaleToFillFrame.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import Kingfisher

extension Image {
    /// 해당 사이즈만큼 비율을 유지하며 꽉 채우게 함
    func scaleToFillFrame(width: CGFloat, height: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: width, height: 280)
            .clipped()
    }
}

extension KFImage {
    /// 해당 사이즈만큼 비율을 유지하며 꽉 채우게 함
    func scaleToFillFrame(width: CGFloat, height: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: width, height: 280)
            .clipped()
    }
}
