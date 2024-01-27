//
//  PopGestureDisableModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI
import Dependencies

extension View {
    /// 스와이프로 네비게이션 가능을 해당 뷰에서만 끔
    func popGestureDisabled() -> some View {
        modifier(PopGestureDisabledViewModifier())
    }

    /// 스와이프로 네비게이션 가능을 다시 키지 않고, 끄기만 함
    ///
    /// - 네비게이션 뷰에서 이동한 뷰가 onAppear, onDisappear 관련해서 키고 끄는 타이밍 이슈가 생기기에 사용
    func popGestureOnlyDisabled() -> some View {
        modifier(PopGestureDisabledViewModifier(isOnlyDisable: true))
    }

    /// 스와이프로 네비게이션 가능을 다시 킴
    ///
    /// - 네비게이션 뷰에서 이동한 뷰가 onAppear, onDisappear 관련해서 키고 끄는 타이밍 이슈가 생기기에 사용
    func popGestureEnabled() -> some View {
        modifier(PopGestureEnableViewModifier())
    }
}

struct PopGestureDisabledViewModifier: ViewModifier {
    @Dependency(\.userDefaults) var userDefaults
    var isOnlyDisable: Bool = false

    func body(content: Content) -> some View {
        content
            .task {
                print("pop false")
                await userDefaults.setBool(false, .isPopGestureEnabled)
            }
            .onDisappear {
                guard !isOnlyDisable else { return }
                Task {
                    print("pop true")
                    await userDefaults.setBool(true, .isPopGestureEnabled)
                }
            }
    }
}

struct PopGestureEnableViewModifier: ViewModifier {
    @Dependency(\.userDefaults) var userDefaults

    func body(content: Content) -> some View {
        content
            .task {
                await userDefaults.setBool(true, .isPopGestureEnabled)
            }
    }
}
