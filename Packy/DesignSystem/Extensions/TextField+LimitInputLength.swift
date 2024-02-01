//
//  TextField+LimitInputLength.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI
import Combine

extension View {
    func limitTextLength(text: Binding<String>, length: Int) -> some View {
        modifier(TextFieldLimitModifier(text: text, length: length))
    }
}


struct TextFieldLimitModifier: ViewModifier {
    @Binding var text: String
    var length: Int
    func body(content: Content) -> some View {
        content
            .onChange(of: text) {
                text = String($1.prefix(length))
            }
    }
}
