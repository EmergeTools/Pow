import SwiftUI
import AVFoundation

public extension Animation {
    enum MovingParts {

    }

    /// The namespace of Moving Parts animations.
    static var movingParts: MovingParts.Type {
        MovingParts.self
    }
}

public extension AnyTransition {
    enum MovingParts {

    }

    /// The namespace of Moving Parts transitions.
    static var movingParts: MovingParts.Type {
        MovingParts.self
    }
}
