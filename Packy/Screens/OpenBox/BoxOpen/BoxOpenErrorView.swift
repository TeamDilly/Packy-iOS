//
//  BoxOpenErrorView.swift
//  Packy
//
//  Created by Mason Kim on 2/3/24.
//

import SwiftUI
import ComposableArchitecture

struct BoxOpenErrorView: View {
    @ObservedObject private var viewStore: ViewStoreOf<BoxOpenFeature>

    init(viewStore: ViewStoreOf<BoxOpenFeature>) {
        self.viewStore = viewStore
    }

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            VStack(spacing: 16) {
                Text("이 선물박스는 열 수 없어요")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .multilineTextAlignment(.center)

                Text("선물박스는 한 명만 열 수 있어요.\n선물박스의 주인이라면 패키에게 문의해주세요.")
                    .packyFont(.body4)
                    .foregroundStyle(.gray800)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)

            Spacer()

            VStack(spacing: 8) {
                PackyButton(title: "확인", colorType: .black) {
                    viewStore.send(.errorConfirmButtonTapped)
                }
                .padding(.bottom, 8)

                Button("문의하기") {
                    // TODO: 문의하기 액션?
                }
                .buttonStyle(TextButtonStyle())
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    BoxOpenErrorView(
        viewStore: .init(.init(
            initialState: .init(boxId: 0),
            reducer: {
                BoxOpenFeature()
                    ._printChanges()
            }
        ), observe: { $0 })
    )
}
