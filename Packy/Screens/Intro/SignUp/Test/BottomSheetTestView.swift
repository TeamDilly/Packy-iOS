//
//  BottomSheetTestView.swift
//  Packy
//
//  Created by Mason Kim on 1/11/24.
//

import SwiftUI

struct BottomSheetTestView: View {
    @State private var isPresented: Bool = true

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            Button("show sheet") {
                isPresented = true
            }
            .bottomSheet(isPresented: $isPresented, detents: [.height(591)]) {
                bottomSheetContent
            }
        }
    }

    var bottomSheetContent: some View {
        VStack(spacing: 0) {
            Text("선물박스가 도착하면\n알려드릴까요?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .padding(.vertical, 8)

            Text("알림을 허용해주시면 선물이 도착하거나\n친구가 선물을 받을 때 알림을 보내드려요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .packyFont(.body4)
                .foregroundStyle(.gray600)

            Image(.mock)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 240)
                .clipped() // 이미지 사이즈 넘치면 자름
                .padding(.vertical, 40)

            Spacer()

            PackyButton(title: "허용하기") {

            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    BottomSheetTestView()
}
