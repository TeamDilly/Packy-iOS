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
                    let musicCircleSize = BoxElementShape.musicCircle.relativeSize(geometryWidth: width)
                    Circle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: musicCircleSize.width, height: musicCircleSize.height)

                    // 편지 추가 사각형
                    let letterRectangleSize = BoxElementShape.letterRectangle.relativeSize(geometryWidth: width)
                    Rectangle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: letterRectangleSize.width, height: letterRectangleSize.height)

                    // 사진 추가 
                    let photoRectangleSize = BoxElementShape.photoRectangle.relativeSize(geometryWidth: width)
                    Rectangle()
                        .stroke(strokeColor, style: strokeStyle)
                        .frame(width: photoRectangleSize.width, height: photoRectangleSize.height)

                    // 음악 원
                    let giftEllipseSize = BoxElementShape.giftEllipse.relativeSize(geometryWidth: width)
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
