//
//  TabSegmentedControl.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import SwiftUI

struct TabSegmentedControl<Tab: Equatable & CustomStringConvertible>: View {
    @Binding var selectedTab: Tab
    @State private var frames: [CGRect] = [.zero, .zero]
    let selections: [Tab]

    private var selectedIndex: Int {
        selections.firstIndex(of: selectedTab) ?? 0
    }

    var body: some View {
        VStack {
            ZStack {
                HStack(spacing: 10) {
                    ForEach(Array(selections.enumerated()), id: \.offset) { index, selection in
                        let isSelected = selectedTab == selection

                        Text(selection.description)
                            .packyFont(isSelected ? .body1 : .body2)
                            .foregroundStyle(isSelected ? .gray900 : .gray600)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTab = selection
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
    enum Tab: CaseIterable, CustomStringConvertible {
        case one
        case two

        var description: String {
            switch self {
            case .one:  return "다가오는 기념일"
            case .two:  return "지난 기념일"
            }
        }
    }

    struct SampleView: View {
        @State private var selectedTab: Tab = .one

        var body: some View {
            TabSegmentedControl(
                selectedTab: $selectedTab,
                selections: Tab.allCases
            )
            .border(Color.black)
            .padding(.horizontal)
            .onChange(of: selectedTab) { oldValue, newValue in
                print(newValue.description)
            }
        }
    }

    return SampleView()
}
