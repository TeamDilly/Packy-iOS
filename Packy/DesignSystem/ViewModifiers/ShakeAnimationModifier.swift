//
//  ShakeAnimationModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/6/24.
//

import SwiftUI

// MARK: - View Modifiers

extension View {
    func shake(isOn: Binding<Bool>, _ configuration: ShakeConfiguration = .init()) -> some View {
        modifier(ShakeModifier(isOn: isOn, configuration: configuration))
    }

    func shakeRepeat(_ configuration: ShakeConfiguration = .init()) -> some View {
        modifier(ShakeForeverModifier(configuration: configuration))
    }
}

// MARK: - Configuration

struct ShakeConfiguration {
    var xIntensity: CGFloat = 5
    var rotationIntensity: CGFloat = 5
    var duration: CGFloat = 1
    var numberOfShakes: CGFloat = 2

    static let string: ShakeConfiguration = .init()
    static let medium: ShakeConfiguration = .init(xIntensity: 2, duration: 1, numberOfShakes: 2)
    static let weak: ShakeConfiguration = .init(xIntensity: 1, rotationIntensity: 3, duration: 1, numberOfShakes: 2)
    static let veryWeak: ShakeConfiguration = .init(xIntensity: 1, rotationIntensity: 2, duration: 2, numberOfShakes: 2)
}

// MARK: - Shake Forever Modifier

struct ShakeForeverModifier: ViewModifier {
    var configuration: ShakeConfiguration = ShakeConfiguration()
    @State private var shakes: CGFloat = 0.0

    func body(content: Content) -> some View {
        content
            .modifier(
                ShakeAnimationModifier(
                    shakes: shakes,
                    xIntensity: configuration.xIntensity,
                    rotationIntensity: configuration.rotationIntensity
                )
            )
            .task {
                withAnimation(
                    .bouncy(duration: configuration.duration).repeatForever()
                ) {
                    shakes = configuration.numberOfShakes
                }
            }
    }
}

// MARK: - Shake Modifier

struct ShakeModifier: ViewModifier {
    @Binding var isOn: Bool
    var configuration: ShakeConfiguration = ShakeConfiguration()
    @State private var shakes: CGFloat = 0.0

    func body(content: Content) -> some View {
        content
            .modifier(
                ShakeAnimationModifier(
                    shakes: shakes,
                    xIntensity: configuration.xIntensity,
                    rotationIntensity: configuration.rotationIntensity
                )
            )
            .onChange(of: isOn) { _ in
                guard isOn else { return }

                Task { @MainActor in
                    withAnimation(
                        .bouncy(duration: configuration.duration)
                    ) {
                        shakes = configuration.numberOfShakes
                    }

                    try? await Task.sleep(for: .seconds(configuration.duration))
                    isOn = false
                    shakes = 0
                }
            }
    }
}

// MARK: - Shake View

struct ShakeView<Content: View>: View {
    @Binding var isOn: Bool
    let content: Content

    var configuration: ShakeConfiguration = ShakeConfiguration()

    @State private var shakes: CGFloat = 0.0

    var body: some View {
        content
            .modifier(
                ShakeAnimationModifier(
                    shakes: shakes,
                    xIntensity: configuration.xIntensity,
                    rotationIntensity: configuration.rotationIntensity
                )
            )
            .onChange(of: isOn) { _ in
                guard isOn else { return }

                Task { @MainActor in
                    withAnimation(
                        .bouncy(duration: configuration.duration)
                    ) {
                        shakes = configuration.numberOfShakes
                    }

                    try? await Task.sleep(for: .seconds(configuration.duration))
                    isOn = false
                    shakes = 0
                }
            }
    }
}

// MARK: - Shake Animation Modifier

private struct ShakeAnimationModifier: ViewModifier, Animatable {
    var shakes: CGFloat
    var xIntensity: CGFloat
    var rotationIntensity: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * xIntensity)
            .rotationEffect(.degrees(Double(sin(shakes * .pi * 2) * rotationIntensity)))
    }
}

// MARK: - Preview

#Preview {
    struct ShakeSampleView: View {
        @State private var isOn = false

        var body: some View {
            VStack {
                Image(.calendar)
                    .shakeRepeat(.veryWeak)
                // .shake(isOn: $isOn)

                Button("Shake On") {
                    isOn = true
                }
            }
            .onChange(of: isOn) {
                print($0)
            }
        }
    }

    return ShakeSampleView()
}
