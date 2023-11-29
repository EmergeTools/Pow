import SwiftUI

protocol Simulative {
    var impulseCount: Int { get set }

    var initialVelocity: CGFloat { get set }
}

internal struct AnySimulativeViewModifier: ViewModifier {
    private var _body: (AnyView) -> AnyView

    init<Modifier: ViewModifier & Simulative>(_ modifier: Modifier) {
        self._body = { content in
            AnyView(content.modifier(modifier))
        }
    }

    func body(content: Content) -> AnyView {
        _body(AnyView(content))
    }
}

internal extension ViewModifier where Self: Simulative {
    func eraseToAnySimulativeViewModifier() -> AnySimulativeViewModifier {
        AnySimulativeViewModifier(self)
    }
}
