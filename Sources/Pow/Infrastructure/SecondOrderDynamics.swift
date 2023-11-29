import SwiftUI

internal struct SecondOrderDynamics<V: VectorArithmetic> {
    var k1: Double

    var k2: Double

    var k3: Double

    var previousTarget: V

    var value: V

    var velocity: V = .zero

    /// - Parameters:
    ///   - f: The natural frequence, in Hz.
    ///   - zeta: The damping coefficient.
    ///   - r: The initial response of the system.
    init(f: Double = 1, zeta: Double = 0.5, r: Double = 2, x0: V = .zero) {
        self.k1 = zeta / (.pi * f)
        self.k2 = 1 / pow(2 * .pi * f, 2)
        self.k3 = (r * zeta) / (2 * .pi * f)

        self.previousTarget = x0
        self.value = x0
    }

    mutating func update(target: V, timestep: TimeInterval) -> V {
        let xd = (target - previousTarget) / timestep
        previousTarget = target

        let stableK2 = max(k2, 1.1 * (timestep * timestep / 4 + timestep * k1 / 2))

        value    = value + velocity * timestep
        velocity = velocity + ((target + (xd * k3) - value - (velocity * k1)) / stableK2) * timestep

        return value
    }
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
