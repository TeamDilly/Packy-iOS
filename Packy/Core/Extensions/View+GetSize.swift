//
//  ViewHeightKey.swift
//  Packy
//
//  Created by Mason Kim on 1/9/24.
//

import SwiftUI

extension View {
    func getSize(sizedChanged: @escaping (CGSize) -> Void) -> some View {
        modifier(GetSizeModifier(
            sizedChanged: sizedChanged
        ))
    }
}

struct GetSizeModifier: ViewModifier {
    let sizedChanged: (CGSize) -> Void

    init(sizedChanged: @escaping (CGSize) -> Void) {
        self.sizedChanged = sizedChanged
    }

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                        .onPreferenceChange(SizePreferenceKey.self) { sizedChanged($0) }
                }
            )
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
