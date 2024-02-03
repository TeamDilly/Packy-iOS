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
    @ObservedObject private var viewStore: ViewStoreOf<BoxOpenFeature>

    init(store: StoreOf<BoxOpenFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            switch viewStore.showingState {
            case .openBox:
                if let giftBox = viewStore.giftBox {
                    openBoxContent(giftBox)
                }
            case .openMotion:
                motionView
            }
        }
        .task {
            await viewStore
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
                // TODO: dismiss
            }
            Spacer()

            Text("\(giftBox.receiverName)님이 보낸\n선물박스가 도착했어요!")
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

            // TODO: Shake Animation!
            NetworkImage(url: giftBox.box.boxFullUrl)
                .frame(width: 240, height: 240)
                .padding(.bottom, 20)

            Spacer()
            Spacer()

            PackyButton(title: "열어보기", colorType: .black) {
                viewStore.send(.openBoxButtonTapped, animation: .spring)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    var motionView: some View {
        Text("Motion Design")
    }
}

// MARK: - Preview

#Preview {
    BoxOpenView(
        store: .init(
            initialState: .init(boxId: 0),
            reducer: {
                BoxOpenFeature()
                    ._printChanges()
            }
        )
    )
}
