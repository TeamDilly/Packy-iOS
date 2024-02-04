//
//  HomeView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct HomeView: View {
    private let store: StoreOf<HomeFeature>
    @ObservedObject private var viewStore: ViewStoreOf<HomeFeature>

    init(store: StoreOf<HomeFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            content
        } destination: { state in
            switch state {

            case .myBox:
                CaseLet(
                    \HomeNavigationPath.State.myBox,
                     action: HomeNavigationPath.Action.myBox,
                     then: MyBoxView.init
                )

            case .boxDetail:
                CaseLet(
                    \HomeNavigationPath.State.boxDetail,
                     action: HomeNavigationPath.Action.boxDetail,
                     then: BoxDetailView.init
                )

            case .boxOpen:
                CaseLet(
                    \HomeNavigationPath.State.boxOpen,
                     action: HomeNavigationPath.Action.boxOpen,
                     then: BoxOpenView.init
                )

            case .setting:
                CaseLet(
                    \HomeNavigationPath.State.setting,
                     action: HomeNavigationPath.Action.setting,
                     then: SettingView.init
                )

            case .manageAccount:
                CaseLet(
                    \HomeNavigationPath.State.manageAccount,
                     action: HomeNavigationPath.Action.manageAccount,
                     then: ManageAccountView.init
                )

            case .deleteAccount:
                CaseLet(
                    \HomeNavigationPath.State.deleteAccount,
                     action: HomeNavigationPath.Action.deleteAccount,
                     then: DeleteAccountView.init
                )

            case .makeBox:
                CaseLet(
                    \HomeNavigationPath.State.makeBox,
                     action: HomeNavigationPath.Action.makeBox,
                     then: MakeBoxView.init
                )

            case .boxChoice:
                CaseLet(
                    \HomeNavigationPath.State.boxChoice,
                     action: HomeNavigationPath.Action.boxChoice,
                     then: BoxChoiceView.init
                )

            case .startGuide:
                CaseLet(
                    \HomeNavigationPath.State.startGuide,
                     action: HomeNavigationPath.Action.startGuide,
                     then: BoxStartGuideView.init
                )

            case .addTitle:
                CaseLet(
                    \HomeNavigationPath.State.addTitle,
                     action: HomeNavigationPath.Action.addTitle,
                     then: BoxAddTitleAndShareView.init
                )
            }
        }
    }
}

// MARK: - Inner Views

private extension HomeView {
    var content: some View {
        VStack(spacing: 16) {
            navigationBar
                .padding(.top, 8)

            NavigationLink(state: HomeNavigationPath.State.makeBox()) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.black)
                    .frame(height: 320)
            }

            VStack(spacing: 24) {
                HStack {
                    Text("주고받은 선물박스")
                        .packyFont(.heading2)
                        .foregroundStyle(.gray900)

                    Spacer()

                    NavigationLink("더보기", state: HomeNavigationPath.State.myBox())
                        .buttonStyle(.text)
                }
                .padding(.horizontal, 24)


                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(1...10, id: \.self) { index in
                            // TODO: 실제 연결 필요
                            BoxInfoCell(
                                boxUrl: "https://picsum.photos/200",
                                sender: "hello",
                                boxTitle: String(repeating: "선물", count: index)
                            )
                        }
                    }
                }
                .safeAreaPadding(.horizontal, 24)
                .scrollIndicators(.hidden)
            }
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
            )


            Spacer()
        }
        .padding(.horizontal, 16)
        .background(.gray100)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }

    var navigationBar: some View {
        HStack {
            Image(.logo)

            Spacer()

            NavigationLink(state: HomeNavigationPath.State.setting()) {
                Image(.setting)
            }
        }
        .frame(height: 48)
    }
}

private struct BoxInfoCell: View {
    var boxUrl: String
    var sender: String
    var boxTitle: String

    var body: some View {
        VStack(spacing: 0) {
            NetworkImage(url: boxUrl)
                .mask(RoundedRectangle(cornerRadius: 8))
                .frame(height: 138)
                .padding(.bottom, 12)

            Text("From: \(sender)")
                .packyFont(.body6)
                .foregroundStyle(.purple500)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            Text(boxTitle)
                .packyFont(.body3)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .frame(width: 120)
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        store: .init(
            initialState: .init(),
            reducer: {
                HomeFeature()
                    ._printChanges()
            }
        )
    )
}
