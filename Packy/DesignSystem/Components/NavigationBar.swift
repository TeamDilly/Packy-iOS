//
//  NavigationBar.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI

struct NavigationBar: View {
    var title: String?
    var leftIcon: Image?
    var leftIconAction: () -> Void = {}
    var rightIcon: Image?
    var rightIconAction: () -> Void = {}

    var body: some View {
        HStack {
            iconView(image: leftIcon, action: leftIconAction)

            Spacer()

            if let title {
                Text(title)
                    .packyFont(.body1)
                    .foregroundStyle(.gray900)
            }

            Spacer()

            iconView(image: rightIcon, action: rightIconAction)
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func iconView(image: Image?, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            if let image {
                image
            } else {
                EmptyView()
            }
        }
        .frame(width: 40, height: 40)
    }
}

extension NavigationBar {
    static func onlyBackButton(action: @escaping () -> Void) -> Self {
        NavigationBar(leftIcon: Image(.arrowLeft), leftIconAction: {
            action()
        })
    }
}

#Preview {
    VStack {
        NavigationBar(title: "Title", leftIcon: Image(.arrowLeft), leftIconAction: { print("back") })
            .border(Color.black)

        NavigationBar(leftIcon: Image(.arrowLeft), leftIconAction: { print("back") })
            .border(Color.black)

        NavigationBar(title: "Title", leftIcon: Image(.arrowLeft), leftIconAction: { print("back") }, rightIcon: Image(.person), rightIconAction: { print("person") })
            .border(Color.black)
    }
}
