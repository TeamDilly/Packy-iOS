//
//  BottomMenuModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/17/24.
//

import SwiftUI

extension View {
    /// 글로벌하게 사용하기 위한 BottomMenu 설정 - App 단에서 1번만 등록하면 됨
    func globalBottomMenu() -> some View {
        modifier(BottomMenuModifier())
    }
}

struct BottomMenuModifier: ViewModifier {
    @ObservedObject var manager = BottomMenuManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            ZStack(alignment: .bottom) {
                Color.black
                    .ignoresSafeArea()
                    .opacity(manager.isPresented ? 0.6 : 0)
                    .onTapGesture {
                        manager.dismiss()
                    }

                if manager.isPresented {
                    BottomMenu(
                        confirmTitle: manager.configuration.confirmTitle,
                        cancelTitle: manager.configuration.cancelTitle,
                        confirmAction: {
                            await manager.configuration.confirmAction()
                            manager.dismiss()
                        },
                        cancelAction: {
                            manager.dismiss()
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
            .zIndex(2)
            .animation(.spring(duration: 0.4), value: manager.isPresented)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}


#Preview {
    struct SampleView: View {
        var body: some View {
            VStack {
                Button("delete!") {
                    Task {
                        await BottomMenuManager.shared.show(
                            configuration: .init(
                                confirmTitle: "삭제하기",
                                confirmAction: {
                                    try? await Task.sleep(for: .seconds(1))
                                    print("완료")
                                }
                            )
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .globalBottomMenu()
            .background(.gray)
        }
    }

    return SampleView()
}
