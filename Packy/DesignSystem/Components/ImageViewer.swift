//
//  ImageViewer.swift
//  Packy
//
//  Created by Mason Kim on 1/30/24.
//

import SwiftUI

struct ImageViewer<ImageContent: View>: View {

    let imageContent: ImageContent
    let dismissedImage: () -> Void

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    @State private var offset: CGPoint = .zero
    @State private var lastTranslation: CGSize = .zero

    init(
        @ViewBuilder imageContent: () -> ImageContent,
        dismissedImage: @escaping () -> Void = {}
    ) {
        self.imageContent = imageContent()
        self.dismissedImage = dismissedImage
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                imageContent
                    .scaleEffect(scale)
                    .offset(x: offset.x, y: offset.y)
                    .gesture(dragGesture(size: proxy.size))
                    .gesture(magnificationGesture(size: proxy.size))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }


}

// MARK: - Inner Functions

private extension ImageViewer {
    /// 확대를 위한 제스쳐
    func magnificationGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value

                guard abs(1 - delta) > 0.01 else { return }
                withAnimation(.spring(duration: 0.1)) {
                    scale *= delta
                }
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1 {
                    withAnimation {
                        scale = 1
                    }
                }
                adjustMaxOffset(size: size)
            }
    }

    /// 이동을 위한 제스쳐
    func dragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let translationChange = CGPoint(
                    x: value.translation.width - lastTranslation.width,
                    y: value.translation.height - lastTranslation.height
                )
                withAnimation(.spring(duration: 0.1)) {
                    offset = offset + translationChange
                }
                lastTranslation = value.translation
            }
            .onEnded { value in
                adjustMaxOffset(size: size)

                if abs(value.velocity.height) > 1000 {
                    dismissedImage()
                }
            }
    }

    func adjustMaxOffset(size: CGSize) {
        let maxOffsetX = (size.width * (scale - 1)) / 2
        let maxOffsetY = (size.height * (scale - 1)) / 2

        var newOffsetX = offset.x
        var newOffsetY = offset.y

        if abs(newOffsetX) > maxOffsetX {
            newOffsetX = maxOffsetX * (abs(newOffsetX) / newOffsetX)
        }
        if abs(newOffsetY) > maxOffsetY {
            newOffsetY = maxOffsetY * (abs(newOffsetY) / newOffsetY)
        }

        let newOffset = CGPoint(x: newOffsetX, y: newOffsetY)
        if newOffset != offset {
            withAnimation {
                offset = newOffset
            }
        }
        self.lastTranslation = .zero
    }
}

private extension CGPoint {
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Rectangle()
            .fill(Gradient(colors: [.blue, .pink300]))
            .ignoresSafeArea()

        ImageViewer {
            NetworkImage(url: Constants.mockImageUrl, contentMode: .fit)
                .padding(.horizontal, 55)
        }
    }
}
