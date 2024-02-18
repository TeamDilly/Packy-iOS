//
//  ViewDidLoadModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import SwiftUI

extension View {
    func didLoad(taskAction: @escaping () async -> Void) -> some View {
        modifier(ViewDidLoadModifier(taskAction: taskAction))
    }
}

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    let taskAction: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard didLoad == false else { return }
                didLoad = true
                await taskAction()
            }
    }
}
