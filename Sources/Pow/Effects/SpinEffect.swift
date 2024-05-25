import SwiftUI

public extension AnyChangeEffect {
    /// The rate of the spin effect.
    enum SpinRate {
        case `default`
        case fast
        case velocity(initial: Angle, maximum: Angle, additional: Angle)

        fileprivate var initialVelocity: Angle {
            switch self {
            case .fast: return .degrees(900)
            case .default: return .degrees(360)
            case .velocity(let initial, _, _): return initial
            }
        }

        fileprivate var maximumVelocity: Angle {
            switch self {
            case .fast: return .degrees(360 * 4)
            case .default: return .degrees(360 * 2)
            case .velocity(_, let maximum, _): return maximum
            }
        }

        fileprivate var additionalVelocity: Angle {
            switch self {
            case .fast: return .degrees(900)
            case .default: return .degrees(360)
            case .velocity(_, _, let additional): return additional
            }
        }
    }

    /// An effect that spins the view when a change happens.
    static var spin: AnyChangeEffect {
        spin(axis: (0, 1, 0))
    }

    /// An effect that spins the view when a change happens.
    ///
    /// - Parameters:
    ///   - axis: The x, y and z elements that specify the axis of rotation.
    ///   - anchor: The location with a default of center that defines a point in 3D space about which the rotation is anchored.
    ///   - anchorZ: The location with a default of 0 that defines a point in 3D space about which the rotation is anchored.
    ///   - perspective: The relative vanishing point with a default of 1 / 6 for this rotation.
    ///   - perspective: An additional multipler you can provide to speed up the animation's runtime.
    ///   - rate: The rate of the spin.
    static func spin(axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint = .center, anchorZ: CGFloat = 0, perspective: CGFloat = 1 / 6, multiplier speedBoost: CGFloat = 0.0, rate: SpinRate = .default) -> AnyChangeEffect {
        .simulation { change in
            SpinSimulationModifier(impulseCount: change, axis: axis, anchor: anchor, anchorZ: anchorZ, perspective: perspective, additionalSpeed: speedBoost, rate: rate)
        }
    }
}

internal struct SpinSimulationModifier: ViewModifier, Simulative {
    var impulseCount: Int

    var initialVelocity: CGFloat = 0

    let spring = Spring(zeta: 1 / 2, stiffness: 7)

    var axis: (x: CGFloat, y: CGFloat, z: CGFloat)

    var anchor: UnitPoint

    var anchorZ: CGFloat

    var perspective: CGFloat

    var additionalSpeed: CGFloat

    var rate: AnyChangeEffect.SpinRate

    @State
    private var targetAngle: Angle = .zero

    @State
    private var angle: Angle = .zero

    @State
    private var angleVelocity: Angle = .zero

    private var transformEffect: some ViewModifier {
        Transform3DEffect(
            translation: (0, 0, anchorZ),
            angle: angle,
            axis: (axis.x, axis.y, axis.z),
            anchor: anchor,
            anchorZ: anchorZ,
            perspective: perspective
        )
        .shaded(lightSource: (-0.5, -1, 0))
    }

    private var isSimulationPaused: Bool {
        targetAngle == angle && abs(angleVelocity.degrees) <= 0.2
    }

    public func body(content: Content) -> some View {
        TimelineView(.animation(paused: isSimulationPaused)) { context in
            content
                .modifier(transformEffect)
                .onChange(of: context.date) { (newValue: Date) in
                    let duration = Double(newValue.timeIntervalSince(context.date))
                    withAnimation(nil) {
                        update(max(0, min(duration, 1 / 30)))
                    }
                }
        }
        .onChange(of: impulseCount) { newValue in
            withAnimation(nil) {
                if angleVelocity <= .degrees(10) {
                    angleVelocity = rate.initialVelocity
                } else {
                    angleVelocity += rate.additionalVelocity
                }

                angleVelocity = min(angleVelocity, rate.maximumVelocity)
            }
        }
    }

    private func update(_ step: Double) {
        let newValue: Double
        let newVelocity: Double

        if abs(angleVelocity.degrees) > 240 {
            newValue = angle.degrees + angleVelocity.degrees * step
            newVelocity = angleVelocity.degrees * (0.99 - self.additionalSpeed)
            targetAngle = .degrees((angle.degrees / 360.0).rounded(.up) * 360.0)
        } else if spring.response > 0 {
            (newValue, newVelocity) = spring.value(
                from: angle.degrees,
                to: targetAngle.degrees,
                velocity: angleVelocity.degrees,
                timestep: step
            )
        } else {
            newValue = targetAngle.degrees
            newVelocity = .zero
        }

        angle = .degrees(newValue)
        angleVelocity = .degrees(newVelocity)

        if abs(newValue - targetAngle.degrees) < 0.04, newVelocity < 0.04 {
            angle = targetAngle
            angleVelocity = .zero
        }
    }
}

#if os(iOS) && DEBUG
struct SpinSimulation_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var impulseCount = 0

        var body: some View {

            VStack {
                ZStack {
                    Circle().fill(.red)

                    Image(systemName: "circle.and.line.horizontal")
                        .font(.system(size: 40))
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)
                .changeEffect(.spin(axis: (1, 0, 0)), value: impulseCount)

                if #available(iOS 16.0, *) {
                    ZStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 40))
                            .imageScale(.large)
                            .foregroundStyle(.blue.gradient)
                    }
                    .changeEffect(.spin(axis: (0, 1, 0), rate: .fast), value: impulseCount)
                    .frame(width: 100, height: 100)
                }

                ZStack {
                    Circle().fill(.yellow)

                    Image(systemName: "circle.and.line.horizontal")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 40))
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)
                .changeEffect(.spin(axis: (0, 1, 0)), value: impulseCount)

                ZStack {
                    Circle().fill(.green)

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 40))
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)
                .changeEffect(.spin(axis: (0, 0, 1)), value: impulseCount)

                ZStack {
                    Circle().fill(.blue)

                    Image(systemName: "circle.and.line.horizontal")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 40))
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)
                .changeEffect(.spin(axis: (1, 1, 0)), value: impulseCount)

                ZStack {
                    Circle().fill(.blue)

                    Image(systemName: "circle.and.line.horizontal")
                        .rotationEffect(.degrees(-45))
                        .font(.system(size: 40))
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)
                .changeEffect(.spin(axis: (-1, 1, 0), anchorZ: -100), value: impulseCount)

                Button("Spin") {
                    impulseCount += 1
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    struct Preview2: View {
        @State
        var text = ""

        var body: some View {
            VStack(alignment: .trailing) {
                VStack(alignment: .leading, spacing: 0) {
                    TextEditor(text: $text)
                        .mask({
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                        })
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.gray)
                        })
                        .frame(height: 140)

                    Text(text.count.formatted())
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(.gray, in: Capsule())
                        .changeEffect(.spin(axis: (1, 0, 0), anchor: .top), value: text.count)
                        .mask(Rectangle())
                }

                Button("Send") {

                }
                .buttonStyle(.borderedProminent)
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
                .tint(.green)
            }
            .padding()
        }
    }

    static var previews: some View {
        Group {
            NavigationView {
                Preview()
            }

            NavigationView {
                Preview2()
            }
        }
    }
}
#endif
