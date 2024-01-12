//
//  SpinningModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import Combine

extension View {
    func spinning(isOn: Bool = true, degreePerSecond: Double = 30) -> some View {
        modifier(
            SpinningModifier(isOn: isOn, degreePerSecond: degreePerSecond)
        )
    }
}

struct SpinningModifier: ViewModifier {

    var isOn: Bool

    init(isOn: Bool, degreePerSecond: Double) {
        self.isOn = isOn
        let interval = 1 / degreePerSecond
        self.timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }

    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    @State private var rotationDegree: Double = 0
    @State private var amountOfIncrease: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotationDegree))
            .onAppear {
                amountOfIncrease = isOn ? 1 : 0
            }
            .onReceive(timer) { _ in
                if isOn {
                    rotationDegree += amountOfIncrease
                    rotationDegree = rotationDegree.truncatingRemainder(dividingBy: 360)
                }
            }
            .onChange(of: isOn) {
                amountOfIncrease = $1 ? 1 : 0
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }
}

#Preview {
    struct SampleView: View {
        @State private var isOn: Bool = true
        var body: some View {
            VStack {
                Button("on/off") {
                    isOn.toggle()
                }

                Image(.bell)
                    .spinning(isOn: isOn)
            }
        }
    }

    return SampleView()
}
