//
//  AlertButtonTint.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import SwiftUI

extension View {
    func alertButtonTint(color: Color) -> some View {
        modifier(AlertButtonTintColor(color: color))
    }
}

struct AlertButtonTintColor: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .onAppear {
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(color)
            }
    }
}
