import SwiftUI

/// A type-erased change effect.
public struct AnyChangeEffect {
    private var modifier: (Int) -> AnyViewModifier

    private var animation: Animation?

    internal var cooldown: Double

    internal var delay: Double = 0

    fileprivate init(modifier: @escaping (Int) -> AnyViewModifier, animation: Animation?, cooldown: Double) {
        self.modifier = modifier
        self.animation = animation
        self.cooldown = cooldown
    }

    internal func viewModifier(changeCount: Int) -> some ViewModifier {
        modifier(changeCount)
            .animation(animation)
    }

    public func delay(_ delay: Double) -> Self {
        var copy = self
        copy.delay = delay

        return copy
    }
}

extension AnyChangeEffect {
    static func animation<Modifier: ViewModifier & Animatable>(_ makeModifier: @escaping (Int) -> Modifier, animation: Animation? = .default, cooldown: Double = 0.33) -> AnyChangeEffect {
        AnyChangeEffect(
            modifier: { change in
                makeModifier(change)
                    .eraseToAnyViewModifier()
            },
            animation: animation,
            cooldown: cooldown
        )
    }

    static func simulation<Modifier: ViewModifier & Simulative>(_ makeModifier: @escaping (Int) -> Modifier) -> AnyChangeEffect {
        AnyChangeEffect(modifier: { change in
            makeModifier(change).eraseToAnyViewModifier()
        }, animation: nil, cooldown: 0.0)
    }
}
