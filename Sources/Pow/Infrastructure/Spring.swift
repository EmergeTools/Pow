import SwiftUI

internal struct Spring {
    var mass: Double

    var stiffness: Double

    var zeta: Double

    init(zeta: Double, stiffness: Double, mass: Double = 1.0) {
        self.zeta = zeta
        self.stiffness = stiffness
        self.mass = mass
    }

    func value<V: VectorArithmetic>(from source: V, to target: V, velocity: V = .zero, timestep: TimeInterval) -> (V, V) {
        let displacement = source - target
        let springForce  = displacement * -stiffness
        let dampingForce = velocity * -dampingCoefficient
        let force        = springForce + dampingForce
        let acceleration = force / mass

        let newVelocity = velocity + acceleration * timestep
        let newValue    = source + newVelocity * timestep

        return (newValue, newVelocity)
    }

    func value<V: VectorArithmetic>(initialPosition x0: V, initialVelocity v0: V, at t: TimeInterval) -> V {
        let unit: V

        switch (x0, v0) {
        case (.zero, .zero):
            return .zero
        case (.zero, let v0) where v0 != .zero:
            unit = v0 / sqrt(v0.magnitudeSquared)
        case (let x0, _):
            unit = x0 / sqrt(x0.magnitudeSquared)
        }

        let m: Double = sqrt(x0.magnitudeSquared)
        let v: Double = sqrt(v0.magnitudeSquared)

        let s: Double

        if zeta < 1 {
            s = -exp(-delta * t) * (m * cos(omega1 * t) + ((delta * m + v) / omega1) * sin(omega1 * t))
        } else if zeta == 1 {
            s = -exp(-delta * t) * (m + (delta * m + v) * t)
        } else {
            s = -exp(-delta * t) * (m * cosh(omega2 * t) + ((delta * m + v) / omega2) * sinh(omega2 * t))
        }

        return x0 + unit * s
    }

    func peakTime<V: VectorArithmetic>(initialPosition x0: V, initialVelocity v0: V) -> Double {
        guard x0 != .zero || v0 != .zero else { return 0 }

        if zeta < 1 {
            guard v0 != .zero else { return .pi / omega1 }

            let m: Double = sqrt(x0.magnitudeSquared)
            let v: Double = sqrt(v0.magnitudeSquared)

            func derivative(t: Double) -> Double {
                (exp(-delta * t) * (-omega1 * v * cos(omega1 * t) + (v * delta + m * (pow(omega1, 2) + pow(delta, 2))) * sin(omega1 * t))) / omega1
            }

            return clamp(0, secantMethod(f: derivative, 0, period / (.pi * stiffness)), 3)
        } else {
            guard v0 != .zero else { return 0 }

            // TODO: Calculate correct peak for non-underdamped springs with
            //       `v0 != .zero`
            return 0
        }
    }
}

internal extension Spring {
    var response: Double {
        (2 * .pi) / sqrt(stiffness * mass)
    }
}

private extension Spring {
    var dampingCoefficient: Double {
        4 * .pi * zeta * mass / response
    }

    var criticalDampingCoefficient: Double {
        2 * sqrt(stiffness * mass) * zeta
    }

    var delta: Double {
        criticalDampingCoefficient / (2 * mass)
    }

    var omega0: Double {
        sqrt(stiffness / mass)
    }

    var omega1: Double {
        sqrt(omega0 * omega0 - delta * delta)
    }

    var omega2: Double {
        sqrt(delta * delta - omega0 * omega0)
    }

    var period: Double {
        2 * .pi * sqrt(stiffness / mass)
    }
}


/// Calculate an approximation for the root of `f` between `x0` and `x1`.
private func secantMethod(f: (Double) -> Double, _ x0: Double, _ x1: Double) -> Double {
    let epsilon = 0.01

    var xN = x1 - (f(x1) * (x1 - x0)) / (f(x1)-f(x0))
    var x0 = x1
    var x1 = xN

    while abs(f(xN)) > epsilon {
        xN = x1 - (f(x1) * (x1 - x0)) / (f(x1)-f(x0))
        x0 = x1
        x1 = xN
    }

    return xN
}

private func * <V: VectorArithmetic>(lhs: V, rhs: Double) -> V {
    var copy = lhs
    copy.scale(by: rhs)
    return copy
}

private func / <V: VectorArithmetic>(lhs: V, rhs: Double) -> V {
    var copy = lhs
    copy.scale(by: 1 / rhs)
    return copy
}

private prefix func - <V: VectorArithmetic>(value: V) -> V {
    var copy = value
    copy.scale(by: -1)
    return copy
}

#if os(iOS) && DEBUG
import Charts

@available(iOS 16.0, *)
struct Spring_Previews: PreviewProvider {
    struct Sample: Identifiable {
        var x: Double
        var y: Double

        var id: some Hashable { x }
    }

    struct Example: Identifiable {
        var spring: Spring

        var id: some Hashable {
            spring.zeta
        }

        var name: String {
            "zeta:\(spring.zeta)"
        }
    }

    struct Preview: View {
        @State
        var showDerivatives: Bool = false

        var body: some View {
            VStack {
                Toggle("Derivatives", isOn: $showDerivatives)

                let springs = [
                    Example(spring: Spring(zeta: 0.01, stiffness: 10, mass: 2)),
                    Example(spring: Spring(zeta: 0.33, stiffness: 10, mass: 2)),
                    Example(spring: Spring(zeta: 0.66, stiffness: 10, mass: 2)),
                    Example(spring: Spring(zeta: 0.99, stiffness: 10, mass: 2)),
                ]

                let x0: Double = 0
                let v0: Double = 10

                let xs = stride(from: 0, through: 3, by: 0.01)

                Chart(springs) { example in
                    let spring = example.spring

                    let f = { (t: Double) -> Double in
                        spring.value(initialPosition: x0, initialVelocity: v0, at: t)
                    }

                    let p = spring.peakTime(initialPosition: x0, initialVelocity: v0)

                    let samples = xs.map {
                        Sample(
                            x: $0,
                            y: f($0)
                        )
                    }

                    ForEach(samples) { sample in
                        LineMark(
                            x: .value("x", sample.x),
                            y: .value("y", sample.y),
                            series: .value("spring", example.name)
                        )
                        .foregroundStyle(by: .value("f", example.name))
                    }

                    if showDerivatives {
                        let derivative: [Sample] = xs.map { (t: Double) -> Sample in
                            let m = x0
                            let v = v0

                            let y: Double = (exp(spring.delta * (-t)) * (sin(t * spring.omega1) * (m * (pow(spring.delta, 2) + pow(spring.omega1, 2)) + spring.delta * v) - v * spring.omega1 * cos(t * spring.omega1)))/spring.omega1

                            return Sample(
                                x: t,
                                y: y
                            )
                        }

                        ForEach(derivative) { sample in
                            LineMark(
                                x: .value("x", sample.x),
                                y: .value("y", sample.y),
                                series: .value("spring", example.name + "'")
                            )
                            .foregroundStyle(by: .value("f'", example.name + "'"))
                        }
                    }

                    PointMark(
                        x: .value("x", p),
                        y: .value("y", f(p))
                    )
                    .foregroundStyle(by: .value("peakTime", example.name))
                }
                .aspectRatio(1, contentMode: .fit)
            }
            .padding()
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
