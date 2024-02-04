//
//  MyBoxView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct MyBoxView: View {
    private let store: StoreOf<MyBoxFeature>
    @ObservedObject private var viewStore: ViewStoreOf<MyBoxFeature>

    init(store: StoreOf<MyBoxFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {

            }
            .padding(.top, 8)

            TabSegmentedControl(
                selectedTab: viewStore.$selectedTab,
                selections: MyBoxTab.allCases
            )
            .padding(.top, 26)

            let columns = [GridItem(spacing: 16), GridItem(spacing: 16)]
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(1...10, id: \.self) { index in
                        BoxInfoCell(
                            tabInfo: viewStore.selectedTab,
                            boxUrl: "https://picsum.photos/200",
                            senderReceiver: "hello",
                            boxTitle: String(repeating: "선물", count: index),
                            date: Date()
                        )
                    }
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
            .background(.gray100)
            .safeAreaPadding(.bottom, 30)

            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private struct BoxInfoCell: View {
    var tabInfo: MyBoxTab
    var boxUrl: String
    var senderReceiver: String
    var boxTitle: String
    var date: Date

    var body: some View {
        VStack(spacing: 0) {
            NetworkImage(url: boxUrl)
                .mask(RoundedRectangle(cornerRadius: 8))
                .frame(height: 138)
                .padding(.bottom, 12)

            VStack(spacing: 4) {
                Text("\(tabInfo.senderReceiverPrefix) \(senderReceiver)")
                    .packyFont(.body6)
                    .foregroundStyle(.purple500)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(boxTitle)
                    .packyFont(.body3)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .frame(height: 44, alignment: .top)

                Text(date.formattedString(by: .yyyyMMdd))
                    .packyFont(.body6)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
    }
}

private extension MyBoxTab {
    var senderReceiverPrefix: String {
        switch self {
        case .sentBox:      return "To."
        case .receivedBox:  return "From."
        }
    }
}


// MARK: - Preview

#Preview {
    MyBoxView(
        store: .init(
            initialState: .init(),
            reducer: {
                MyBoxFeature()
                    ._printChanges()
            }
        )
    )
}
