//
//  Snackbar.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI

// extension View {
//     func snackbar(isShown: Binding<Bool>, text: String, location: SnackbarLocation = .bottom) -> some View {
//         modifier(SnackbarModifier(isShown: isShown, text: text, location: location))
//     }
// }
// 
// 
// struct SnackbarModifier: ViewModifier {
//     @Binding var isShown: Bool
//     let text: String
//     var location: SnackbarLocation = .bottom
//     var isFromBottom: Bool {
//         location == .bottom
//     }
// 
//     @State private var runningTask: Task<(), Never>?
// 
//     func body(content: Content) -> some View {
//         ZStack(alignment: isFromBottom ? .bottom : .top) {
//             content
// 
//             if isShown {
//                 Snackbar(text: text, showFromBottom: isFromBottom)
//                     .padding(.top, 72)
//                     .zIndex(1)
//                     .transition(.offset(y: isFromBottom ? 250 : -250))
//                     .gesture(
//                         DragGesture().onEnded(onEnded)
//                     )
//             }
//         }
//         .onChange(of: isShown) {
//             runningTask?.cancel()
//             guard $1 else { return }
//             runningTask = Task {
//                 try? await Task.sleep(for: .seconds(2))
//                 isShown = false
//             }
//         }
//         .animation(.spring, value: isShown)
//     }
// 
//     private func onEnded(value: DragGesture.Value) {
//         let endY = value.translation.height
//         let velocityY = value.velocity.height
//         let isEnoughToClose = isFromBottom ? endY + velocityY > 100 : endY + velocityY < -100
//         guard isEnoughToClose else { return }
//         isShown = false
//     }
// }
// 
// struct Snackbar: View {
//     let text: String
//     var showFromBottom = true
// 
//     var body: some View {
//         Text(text)
//             .packyFont(.body4)
//             .foregroundStyle(.white)
//             .padding(16)
//             .frame(maxWidth: .infinity, alignment: .leading)
//             .background(
//                 RoundedRectangle(cornerRadius: 12)
//                     .fill(.black.opacity(0.8))
//             )
//             .padding(.bottom, 8)
//     }
// }
// 
// #Preview {
//     struct Sample: View {
//         @State private var isShown: Bool = false
//         var body: some View {
//             ZStack {
//                 Color.blue.opacity(0.1).ignoresSafeArea()
// 
//                 VStack {
//                     Button("SHOW") {
//                         isShown = true
//                     }
// 
//                     Spacer()
//                 }
//                 .snackbar(isShown: $isShown, text: "hello world!", location: .bottom)
// 
//                 .padding(.horizontal, 16)
//             }
//         }
//     }
// 
//     return Sample()
// }
