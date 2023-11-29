import SwiftUI

public extension AnyChangeEffect {
    /// An effect that adds one or more shapes that slowly grow and fade-out behind the view.
    ///
    /// - Parameters:
    ///   - shape: The shape to use for the effect.
    ///   - style: The shape style to use for the effect. Defaults to `tint`.
    ///   - count: The number of shapes to emit.
    @available(*, deprecated, renamed: "pulse(shape:style:count:)")
    static func ping(shape: some InsettableShape, style: some ShapeStyle = .tint, count: Int) -> AnyChangeEffect {
        pulse(shape: shape, style: style, count: count)
    }
}
