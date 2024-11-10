import SwiftUI

#if !os(watchOS)
public extension AnyChangeEffect {
    /// An effect that wiggles the view when a change happens.
    static var wiggle: AnyChangeEffect {
        wiggle(rate: .default)
    }

    /// The rate of the wiggle effect.
    enum WiggleRate {
        case `default`
        case fast
        case phaseLength(CGFloat)

        fileprivate var phaseLength: CGFloat {
            switch self {
            case .default: return 0.8
            case .fast: return 0.3
            case .phaseLength(let phaseLength): return phaseLength
            }
        }
    }

    /// An effect that wiggles the view when a change happens.
    ///
    /// - Parameter rate: The rate of the wiggle.
    static func wiggle(rate: WiggleRate) -> AnyChangeEffect {
        .simulation({ change in
            WiggleSimulationModifier(impulseCount: change, phaseLength: rate.phaseLength)
        })
    }
}
#endif

#if !os(watchOS)
internal struct WiggleSimulationModifier: ViewModifier, Simulative {
    // TODO: Not used, remove from protocol
    var initialVelocity: CGFloat = 0

    var impulseCount: Int

    var phaseLength: CGFloat

    @Environment(\.isConditionalEffect)
    private var isConditionalEffect

    @State
    private var wiggleCount: CGFloat = 0

    @State
    private var displacement: CGFloat = 0

    @State
    private var integrator: SecondOrderDynamics<CGFloat> = SecondOrderDynamics(
        f: 3,
        zeta: 0.85,
        r: -0.2
    )

    fileprivate var target: CGFloat {
        16 * sin(2 * .pi * wiggleCount)
    }

    private var isSimulationPaused: Bool {
        displacement == .zero && wiggleCount <= 0
    }

    public func body(content: Content) -> some View {
        let t = Transform3DEffect(
            angle: .degrees(displacement / 2),
            axis: (0, 0, 1)
        )

        TimelineView(.animation(paused: isSimulationPaused)) { context in
            content
                .modifier(t)
                .onChange(of: context.date) { (newValue: Date) in
                    let duration = Double(newValue.timeIntervalSince(context.date))
                    withAnimation(nil) {
                        update(max(0, min(duration, 1 / 30)))
                    }
                }
        }
        .onChange(of: impulseCount) { newValue in
            withAnimation(nil) {
                wiggleCount += 2

                if wiggleCount > 3 {
                    wiggleCount = 2 + fmod(wiggleCount, 1)
                }

                if isConditionalEffect {
                    wiggleCount += 4
                }
            }
        }
    }

    private func update(_ step: Double) {
        displacement = integrator.update(target: target, timestep: step)

        if !displacement.isNormal {
            displacement = 0
        }

        wiggleCount = clamp(0, wiggleCount - 2 * (step / phaseLength), .infinity)
    }
}
#endif


#if os(iOS) && DEBUG
struct WiggleEffect_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var value: Int = 0

        var body: some View {
            VStack(spacing: 8) {
                Spacer()

                VStack(spacing: 32) {
                    Label("Answer", systemImage: "phone.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .changeEffect(.wiggle(rate: .fast), value: value)
                        .changeEffect(.shine(angle: .degrees(90), duration: 0.75), value: value)
                        .tint(.green)
                        .font(.largeTitle)
                }

                Spacer()

                Stepper(value: $value) {
                    Text("Value ") + Text("(\(value.formatted()))").foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }

    struct Preview2: View {
        @State
        var isCalling: Bool = false

        var body: some View {
            VStack(spacing: 8) {
                Spacer()

                VStack(spacing: 32) {
                    Label("Answer", systemImage: "phone.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .conditionalEffect(.repeat(.wiggle(rate: .fast), every: 2), condition: isCalling)
                        .tint(.green)
                        .font(.largeTitle)
                }

                Spacer()

                Toggle("Calling", isOn: $isCalling)
            }
            .padding()
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Change Effect")
        Preview2()
            .preferredColorScheme(.dark)
            .previewDisplayName("Conditional Effect")
    }
}
#endif
