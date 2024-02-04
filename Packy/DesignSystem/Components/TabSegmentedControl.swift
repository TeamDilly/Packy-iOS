//
//  TabSegmentedControl.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import SwiftUI

struct TabSegmentedControl: View {
    @Binding var selectedIndex: Int
    @State private var frames: [CGRect] = [.zero, .zero]
    let selections: [String]

    var body: some View {
        VStack {
            ZStack {
                HStack(spacing: 10) {
                    ForEach(Array(selections.enumerated()), id: \.offset) { index, selection in
                        let isSelected = index == selectedIndex

                        Text(selection)
                            .packyFont(isSelected ? .body1 : .body2)
                            .foregroundStyle(isSelected ? .gray900 : .gray600)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedIndex = index
                            }
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        frames[index] = geometry.frame(in: .global)
                                    }
                                }
                            )
                    }
                }
                .background(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(.gray900)
                        .frame(width: frames[selectedIndex].width, height: 3)
                        .offset(x: offset(ofIndex: selectedIndex))
                        .animation(.spring, value: selectedIndex)
                }
            }
        }
    }

    private func offset(ofIndex index: Int) -> CGFloat {
        frames[index].minX - (frames.first?.minX ?? 0)
    }
}

#Preview {
    struct SampleView: View {
        @State private var selectedIndex = 0

        var body: some View {
            TabSegmentedControl(
                selectedIndex: $selectedIndex,
                selections: ["다가오는 기념일", "지난 기념일"]
            )
            .border(Color.black)
            .padding(.horizontal)
        }
    }

    return SampleView()
}
