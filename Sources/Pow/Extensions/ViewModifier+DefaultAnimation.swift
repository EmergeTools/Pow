import SwiftUI

internal extension ViewModifier where Self: Animatable {
    func defaultAnimation(_ animation: Animation) -> some ViewModifier {
        transaction { t in
            if t.animation == .default {
                t.animation = animation
            }
        }
    }
}
