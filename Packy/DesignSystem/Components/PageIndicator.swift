//
//  Indicator.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

struct PageIndicator: View {
    let totalPages: Int
    let currentPage: Int

    var activeColor: Color = .gray900
    var inActiveColor: Color = .gray300

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) {
                let isCurrent = currentPage == $0

                Circle()
                    .fill(isCurrent ? activeColor : inActiveColor)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    PageIndicator(totalPages: 2, currentPage: 1)
}
