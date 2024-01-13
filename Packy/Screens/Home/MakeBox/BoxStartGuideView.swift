//
//  BoxStartGuideView.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxStartGuideView: View {
    private let store: StoreOf<BoxStartGuideFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxStartGuideFeature>
    
    private let strokeColor: Color = .gray400
    private let strokeStyle: StrokeStyle = .init(lineWidth: 1.5, dash: [5])

    init(store: StoreOf<BoxStartGuideFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ScrollView {
                VStack {
                    // 음악 추가 원
                    let musicCircleSize = ShapeElement.musicCircle.relativeSize(geometryWidth: width)
                    Circle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: musicCircleSize.width, height: musicCircleSize.height)

                    // 편지 추가 사각형
                    let letterRectangleSize = ShapeElement.letterRectangle.relativeSize(geometryWidth: width)
                    Rectangle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: letterRectangleSize.width, height: letterRectangleSize.height)

                    // 사진 추가 
                    let photoRectangleSize = ShapeElement.photoRectangle.relativeSize(geometryWidth: width)
                    Rectangle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: photoRectangleSize.width, height: photoRectangleSize.height)

                    // 음악 원
                    let giftEllipseSize = ShapeElement.giftEllipse.relativeSize(geometryWidth: width)
                    Ellipse()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: giftEllipseSize.width, height: giftEllipseSize.height)
                }
            }
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - ShapeElement (도형 사이즈 계산)


extension BoxStartGuideView {
    enum ShapeElement {
        case musicCircle
        case letterRectangle
        case photoRectangle
        case giftEllipse

        var absoluteSize: CGSize {
            switch self {
            case .musicCircle:      return .init(width: 210, height: 210)
            case .letterRectangle:  return .init(width: 163, height: 228)
            case .photoRectangle:   return .init(width: 163, height: 202)
            case .giftEllipse:      return .init(width: 163, height: 189)
            }
        }

        var shapeRatio: CGFloat {
            absoluteSize.height / absoluteSize.width
        }

        func relativeSize(geometryWidth: CGFloat) -> CGSize {
            let standardWidth: CGFloat = 390
            let widthRatio = absoluteSize.width / standardWidth
            let width = geometryWidth * widthRatio
            let height = width * shapeRatio
            return .init(width: width, height: height)
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
