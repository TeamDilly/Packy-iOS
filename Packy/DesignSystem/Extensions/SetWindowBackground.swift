//
//  SetWindowBackground.swift
//  Packy
//
//  Created by Mason Kim on 1/17/24.
//

import SwiftUI

func setWindowBackgroundColor(_ color: Color) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    window.backgroundColor = UIColor(color)
}
