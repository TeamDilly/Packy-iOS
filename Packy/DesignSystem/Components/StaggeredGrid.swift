//
//  StaggeredGrid.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import SwiftUI

struct StaggeredGrid<Content: View, T: Identifiable & Hashable>: View {
    private var content: (T) -> Content
    private var data: [T]
    private var columns: Int

    private var showsIndicators: Bool = false
    private var horizontalSpacing: CGFloat = 16
    private var verticalSpacing: CGFloat = 32
    private var zigzagPadding: CGFloat = 0

    init(
        columns: Int,
        data: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.content = content
        self.data = data
        self.columns = columns
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(arrangedSubarrays.indices, id: \.self) { index in
                    let columnData = arrangedSubarrays[index]
                    VStack(spacing: verticalSpacing) {
                        ForEach(columnData) { object in
                            content(object)
                        }
                    }
                    .padding(.top, index % 2 == 0 ? zigzagPadding : 0)
                }
            }
            .padding(.vertical)
        }
    }

    private var arrangedSubarrays: [[T]] {
        var emptyArray = Array(repeating: [T](), count: columns)
        let gridArray = data.enumerated().reduce(into: emptyArray) { (grid, enumeration) in
            let (index, element) = enumeration
            let columnIndex = (columns - 1) - (index % columns) // 오른쪽에서 왼쪽으로 배치하기 위한 인덱스 계산
            grid[columnIndex].append(element)
        }
        return gridArray
    }
}

// MARK: - View Modifiers

extension StaggeredGrid {
    func innerSpacing(vertical: CGFloat, horizontal: CGFloat) -> Self {
        var copy = self
        copy.horizontalSpacing = horizontal
        copy.verticalSpacing = vertical
        return copy
    }

    func showIndicator(_ showsIndicators: Bool) -> Self {
        var copy = self
        copy.showsIndicators = showsIndicators
        return copy
    }

    func zigzagPadding(_ padding: CGFloat) -> Self {
        var copy = self
        copy.zigzagPadding = padding
        return copy
    }
}

// MARK: - Preview


#Preview {
    struct SampleView: View {
        @State var columns: Int = 2
        @Namespace var animation

        var body: some View {
            VStack {
                Button("change") {
                    if columns == 5 {
                        columns = 1
                    } else {
                        columns += 1
                    }
                }

                StaggeredGrid(columns: columns, data: (0...10).map { $0 }) { number in
                    // if number % 2 == 1 && number <= columns && columns > 1 {
                        cell(number)
                            // .padding(.top, 50)
                    // } else {
                        // cell(number)
                    // }
                }
                .zigzagPadding(50)
                .padding()
                .animation(.spring, value: columns)
            }
        }

        private func cell(_ number: Int) -> some View {
            Text("\(number)")
            // .frame(maxWidth: .infinity)
            // .frame(height: 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.green)
                )
                .matchedGeometryEffect(id: number, in: animation)
                .aspectRatio(163 / 195, contentMode: .fill)
        }
    }

    return SampleView()
}

extension Int: Identifiable {
    public var id: Int { self }
}

