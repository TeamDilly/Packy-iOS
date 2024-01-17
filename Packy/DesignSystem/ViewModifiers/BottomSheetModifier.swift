//
//  BottomSheetModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/11/24.
//

import SwiftUI

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        currentDetent: Binding<PresentationDetent>? = nil,
        detents: Set<PresentationDetent>,
        showLeadingButton: Bool = false,
        leadingButtonAction: (() -> Void)? = nil,
        sheetContent: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheetModifier(isPresented: isPresented, currentDetent: currentDetent, detents: detents, showLeadingButton: showLeadingButton, leadingButtonAction: leadingButtonAction, sheetContent: sheetContent)
        )
    }
}

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var currentDetent: Binding<PresentationDetent>?
    let detents: Set<PresentationDetent>
    let showLeadingButton: Bool
    let leadingButtonAction: (() -> Void)?

    let sheetContent: () -> SheetContent

    func body(content baseContent: Content) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .zIndex(1)
                .opacity(isPresented ? 0.6 : 0)
                .animation(.spring, value: isPresented)

            baseContent
                .sheet(isPresented: $isPresented) {
                    VStack(spacing: 0) {
                        HStack {
                            if showLeadingButton {
                                Button {
                                    leadingButtonAction?()
                                } label: {
                                    Image(.arrowLeft)
                                }
                            }

                            Spacer()
                            CloseButton(colorType: .light) {
                                isPresented = false
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .padding(.top, 8)
                        
                        sheetContent()
                    }
                    .presentationCornerRadius(24)
                    .if(currentDetent == nil) { view in
                        view.presentationDetents(detents)
                    }
                    .ifLet(currentDetent) { view, currentDetent in
                        view.presentationDetents(detents, selection: currentDetent)
                    }
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
                }
        }
        .onAppear {
            setWindowBackgroundColor(.black.opacity(0.6))
        }
    }
}

#Preview {
    VStack {}
        .bottomSheet(isPresented: .constant(true), currentDetent: .constant(.medium), detents: [.medium], showLeadingButton: true) {
            VStack {
                Text("hello")

                Spacer()
            }
        }
}
