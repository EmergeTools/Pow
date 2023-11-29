import SwiftUI

internal struct AnyContinuousEffect {
    private var _viewModifier: (Bool) -> AnyContinuousViewModifier

    static func modifier(_ modifier: @escaping (Bool) -> some ViewModifier & Continuous) -> Self {
        AnyContinuousEffect(_viewModifier: { isActive in
            modifier(isActive).eraseToAnyContinuousViewModifier()
        })
    }

    func viewModifier(_ isActive: Bool) -> AnyContinuousViewModifier {
        _viewModifier(isActive)
    }
}

internal struct AnyContinuousViewModifier: ViewModifier {
    private var _body: (AnyView) -> AnyView

    init<Modifier: ViewModifier & Continuous>(_ modifier: Modifier) {
        self._body = { content in
            AnyView(content.modifier(modifier))
        }
    }

    func body(content: Content) -> AnyView {
        _body(AnyView(content))
    }
}

internal extension ViewModifier where Self: Continuous {
    func eraseToAnyContinuousViewModifier() -> AnyContinuousViewModifier {
        AnyContinuousViewModifier(self)
    }
}

internal protocol Continuous {
    var isActive: Bool { get }
}
