import SwiftUI

internal struct AnyAnimatableViewModifier: ViewModifier, Animatable {
    private var _body: (Content) -> AnyView

    var animatableData: EmptyAnimatableData

    init<Modifier: ViewModifier & Animatable>(_ modifier: Modifier) {
        self._body = { content in
            AnyView(content.modifier(modifier))
        }
        self.animatableData = .zero
    }

    func body(content: Content) -> AnyView {
        _body(content)
    }
}

internal extension ViewModifier where Self: Animatable {
    func eraseToAnyAnimatableViewModifier() -> AnyAnimatableViewModifier {
        AnyAnimatableViewModifier(self)
    }
}
