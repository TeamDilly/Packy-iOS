//
//  BoxChoiceView.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxChoiceView: View {
    private let store: StoreOf<BoxChoiceFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxChoiceFeature>

    @State private var selection: BoxSelectionCategory = .box

    init(store: StoreOf<BoxChoiceFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.gray100.ignoresSafeArea()

                VStack {
                    FloatingNavigationBar {

                    }
                    .padding(.top, 8)

                    Text("박스와 메시지를 골라주세요")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .padding(.top, 56)

                    ZStack {
                        Image(.giftboxForeground1)
                            .offset(x: 35, y: -55)
                            .zIndex(1)

                        Image(.giftboxBackground1)
                    }
                    .padding(.top, 107)

                    Spacer()
                }
            }

            Divider()

            CategorySelector(selection: $selection)
                .frame(height: 56)

            Divider()

            // 박스, 메시지 선택
            ZStack {
                BoxSelector(selectedIndex: viewStore.$selectedBox)
                    .opacity(selection == .box ? 1 : 0)
                    .padding(.vertical, 20)

                MessageSelector(selectedIndex: viewStore.$selectedMessage)
                    .opacity(selection == .message ? 1 : 0)
                    .padding(.vertical, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - BoxSelectionCategory

enum BoxSelectionCategory: CaseIterable {
    case box
    case message

    var description: String {
        switch self {
        case .box:      return "박스"
        case .message:  return "메시지"
        }
    }
}

// MARK: - Inner Views

private struct CategorySelector: View {
    @Binding var selection: BoxSelectionCategory

    var body: some View {
        HStack {
            ForEach(BoxSelectionCategory.allCases, id: \.self) { boxSelection in
                let isSelected = selection == boxSelection
                Text(boxSelection.description)
                    .packyFont(isSelected ? .body1 : .body2)
                    .foregroundStyle(isSelected ? .black : .gray800)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring) {
                            self.selection = boxSelection
                        }
                    }
            }
        }
    }
}

private struct BoxSelector: View {
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    Button {
                        selectedIndex = index
                        HapticManager.shared.fireFeedback(.light)
                    } label: {
                        Image(.mock)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.bouncy)
                }
            }
        }
        .safeAreaPadding(.horizontal, 20)
        .scrollIndicators(.hidden)
    }
}

private struct MessageSelector: View {
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    Button {
                        selectedIndex = index
                        HapticManager.shared.fireFeedback(.light)
                    } label: {
                        Rectangle()
                            .fill(.orange)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.bouncy)
                }
            }
        }
        .safeAreaPadding(.horizontal, 20)
        .scrollIndicators(.hidden)
    }
}

// MARK: - Preview

#Preview {
    BoxChoiceView(
        store: .init(
            initialState: .init(senderInfo: BoxSenderInfo(to: "Mason", from: "Mson")),
            reducer: {
                BoxChoiceFeature()
                    ._printChanges()
            }
        )
    )
}
