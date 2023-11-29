import SwiftUI

internal extension UnitPoint {
    /// Creates a `UnitPoint` from a point on the Unit Circle.
    ///
    /// > Note: The Unit Circle has a radius of 1 and is centered around
    /// > `(0, 0)` whereas SwiftUI's `UnitPoint` is definde in the Unit Square
    /// > which has sides of length 1 and a center of `(0.5, 0.5)`.
    ///
    /// For the point to lie on the circle, it needs to fulfil `u² + v² == 1`.
    ///
    /// - Parameters:
    ///   - u: The horizontal coordinate.
    ///   - v: The vertical coordinate.
    init(u: Double, v: Double) {
        let u_2: Double = pow(u, 2)
        let v_2: Double = pow(v, 2)
        let sq2: Double = sqrt(2.0)

        let x: Double = 0.5 * sqrt(abs(2.0 + u_2 - v_2 + 2.0 * u * sq2)) - 0.5 * sqrt(abs(2.0 + u_2 - v_2 - 2.0 * u * sq2))
        let y: Double = 0.5 * sqrt(abs(2.0 - u_2 + v_2 + 2.0 * v * sq2)) - 0.5 * sqrt(abs(2.0 - u_2 + v_2 - 2.0 * v * sq2))

        self.init(x: (1 + x) / 2, y: (1 + y) / 2)
    }
}
