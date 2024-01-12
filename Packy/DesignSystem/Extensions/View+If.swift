//
//  View+If.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI

extension View {
    /// 특정 Bool 값이 true일 때, apply 클로저를 적용하는 modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, apply: (Self) -> Content) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

    /// 특정 Optional 값이 nil이 아닐 때, apply 클로저를 적용하는 modifier
    @ViewBuilder
    func ifLet<Content: View, Value>(_ optionalValue: Optional<Value>, apply: (Self, Value) -> Content) -> some View {
        if let value = optionalValue {
            apply(self, value)
        } else {
            self
        }
    }
}
