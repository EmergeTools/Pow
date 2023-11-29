import SwiftUI

public extension Animation.MovingParts {
    /// A timing curve that anticipates animating to the target.
    static var anticipate: Animation {
        anticipate(duration: 0.35)
    }

    /// A timing curve that anticipates animating to the target.
    static func anticipate(duration: Double) -> Animation {
        .timingCurve(0.33, 0, 0.66, -0.55, duration: duration)
    }

    /// A timing curve that overshoots the target.
    static var overshoot: Animation {
        overshoot(duration: 0.35)
    }

    /// A timing curve that overshoots the target.
    static func overshoot(duration: Double) -> Animation {
        .timingCurve(0.33, 1.55, 0.66, 1, duration: duration)
    }

    /// A timing curve that anticipates animating to the target and overshoots
    /// it.
    static var anticipateOvershoot: Animation {
        anticipateOvershoot(duration: 0.35)
    }

    /// A timing curve that anticipates animating to the target and overshoots
    /// it.
    static func anticipateOvershoot(duration: Double) -> Animation {
        .timingCurve(0.66, -0.55, 0.33, 1.6, duration: duration)
    }
}

public extension Animation.MovingParts {
    static var easeInExponential: Animation {
        easeInExponential(duration: 0.35)
    }

    static func easeInExponential(duration: Double) -> Animation {
        .timingCurve(0.95, 0.05, 0.795, 0.035, duration: duration)
    }

    static var easeOutExponential: Animation {
        easeOutExponential(duration: 0.35)
    }

    static func easeOutExponential(duration: Double) -> Animation {
        .timingCurve(0.19, 1, 0.22, 1, duration: duration)
    }

    static var easeInOutExponential: Animation {
        easeInOutExponential(duration: 0.35)
    }

    static func easeInOutExponential(duration: Double) -> Animation {
        .timingCurve(1, 0, 0, 1, duration: duration)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct TimingCurves_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var isOn: Bool = false

        var body: some View {
            let shape = Rectangle()
                .fill(.red)
                .frame(width: 64, height: 64)
                .frame(maxWidth: .infinity, alignment: isOn ? .trailing : .leading)

            VStack {
                Toggle(isOn: $isOn) { Text("Toggle Me") }

                shape
                    .animation(.easeInOut, value: isOn)

                shape
                    .animation(.movingParts.easeInExponential, value: isOn)

                shape
                    .animation(.movingParts.anticipate, value: isOn)

                shape
                    .animation(.movingParts.overshoot, value: isOn)

                shape
                    .animation(.movingParts.anticipateOvershoot, value: isOn)

                Spacer()
            }
            .padding()
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
