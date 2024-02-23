//
//  BoxOpenView.swift
//  Packy
//
//  Created Mason Kim on 2/3/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxOpenView: View {
    private let store: StoreOf<BoxOpenFeature>

    init(store: StoreOf<BoxOpenFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            switch store.showingState {
            case .openBox:
                if let giftBox = store.giftBox {
                    openBoxContent(giftBox)
                }
            case .openMotion:
                if let boxDesignId = store.giftBox?.box.designId {
                    BoxMotionView(motionType: .boxArrived(boxDesignId: boxDesignId))
                }

            case .openError:
                BoxOpenErrorView(store: store)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxOpenView {
    func openBoxContent(_ giftBox: ReceivedGiftBox) -> some View {
        VStack(spacing: 0) {
            NavigationBar.onlyLeftCloseButton {
                store.send(.closeButtonTapped)
            }
            Spacer()

            Text("\(giftBox.senderName)님이 보낸\n선물박스가 도착했어요!")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .padding(.top, 24)
                .multilineTextAlignment(.center)

            Text(giftBox.name)
                .packyFont(.body4)
                .foregroundStyle(.gray900)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    Capsule()
                        .fill(.gray100)
                        .stroke(.gray300, style: .init())
                )
                .padding(.top, 20)

            Spacer()

            NetworkImage(url: giftBox.box.boxNormalUrl)
                .shakeRepeat(.veryWeak)
                .frame(width: 240, height: 240)
                .padding(.bottom, 20)
                .bouncyTapGesture {
                    throttle(.seconds(3)) {
                        store.send(.openBoxButtonTapped, animation: .spring)
                    }
                }

            Spacer()
            Spacer()

            PackyButton(title: "열어보기", colorType: .black) {
                throttle(.seconds(3)) {
                    store.send(.openBoxButtonTapped, animation: .spring)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    BoxOpenView(
        store: .init(
            initialState: .init(boxId: 1),
            reducer: {
                BoxOpenFeature()
                    ._printChanges()
            }
        )
    )
}

