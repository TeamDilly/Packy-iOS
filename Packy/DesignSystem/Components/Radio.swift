//
//  Radio.swift
//  Packy
//
//  Created by Mason Kim on 1/9/24.
//

import SwiftUI

struct Radio: View {
    var isSelected: Bool

    var body: some View {
        Image(isSelected ? .radioSelected : .radioUnselected)
            .resizable()
            .frame(width: 20, height: 20)
            .animation(.spring, value: isSelected)
    }
}

#Preview {
    HStack {
        Radio(isSelected: true)
        Radio(isSelected: false)
    }
}
