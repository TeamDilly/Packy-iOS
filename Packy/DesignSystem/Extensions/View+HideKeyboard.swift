//
//  View+HideKeyboard.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func makeTapToHideKeyboard() -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }
}
