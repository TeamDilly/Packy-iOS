//
//  BottomMenuModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/17/24.
//

import SwiftUI

extension View {
    func bottomMenu(
        isPresented: Binding<Bool>,
        confirmTitle: String,
        cancelTitle: String = "취소",
        confirmAction: @escaping () -> Void
    ) -> some View {
        modifier(
            BottomMenuModifier(
                isPresented: isPresented,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                confirmAction: confirmAction
            )
        )
    }
}

struct BottomMenuModifier: ViewModifier {
    @Binding var isPresented: Bool
    let confirmTitle: String
    var cancelTitle: String = "취소"
    let confirmAction: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            ZStack(alignment: .bottom) {
                Color.black
                    .ignoresSafeArea()
                    .opacity(isPresented ? 0.6 : 0)
                    .onTapGesture {
                        isPresented = false
                    }

                if isPresented {
                    BottomMenu(
                        confirmTitle: confirmTitle,
                        cancelTitle: cancelTitle,
                        confirmAction: {
                            confirmAction()
                            isPresented = false
                        },
                        cancelAction: {
                            isPresented = false
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
            .animation(.spring(duration: 0.4), value: isPresented)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}


#Preview {
    struct SampleView: View {
        @State private var isPresented: Bool = false

        var body: some View {
            VStack {
                Button("delete!") {
                    isPresented = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .bottomMenu(
                isPresented: $isPresented,
                confirmTitle: "삭제하기",
                confirmAction: {
                    print("delete")
                }
            )
            .background(.gray)
        }
    }

    return SampleView()
}
