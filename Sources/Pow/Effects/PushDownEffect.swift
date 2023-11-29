import SwiftUI

public extension AnyConditionalEffect {
    /// An effect that pushes down the view while a condition is true.
    static var pushDown: AnyConditionalEffect {
        .continuous(
            .modifier { isActive in
                PressDownEffectModifier(isActive: isActive)
            }
        )
    }
}

// Copy of BounceButtonHighlightModifier
struct PressDownEffectModifier: ViewModifier, Continuous {
    var isActive: Bool

    func body(content: Content) -> some View {
        let animation: Animation = {
            if isActive {
                return .interactiveSpring(response: 0.20, dampingFraction: 0.4)
            } else {
                return .interactiveSpring(response: 0.30, dampingFraction: 0.4, blendDuration: 0.6)
            }
        }()

        let d = isActive ? 0.95 : 1

        content
            .modifier(_ScaleEffect(scale: CGSize(width: d, height: d)).animation(animation))
    }
}
