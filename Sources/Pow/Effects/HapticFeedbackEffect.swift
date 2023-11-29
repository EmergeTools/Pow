#if os(iOS)
import SwiftUI

public extension AnyChangeEffect {
    /// Triggers haptic feedback whenever a value changes.
    ///
    /// - Parameter type: The feedback type to trigger.
    @available(*, deprecated, renamed: "feedback(hapticNotification:)")
    static func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) -> AnyChangeEffect {
        feedback(hapticNotification: type)
    }

    /// Triggers haptic feedback to communicate successes, failures, and warnings whenever a value changes.
    ///
    /// - Parameter notification: The feedback type to trigger.
    static func feedback(hapticNotification type: UINotificationFeedbackGenerator.FeedbackType) -> AnyChangeEffect {
        .simulation { change in
            HapticFeedbackEffect(feedback: .notification(type), impulseCount: change)
        }
    }

    /// Triggers haptic feedback to simulate physical impacts whenever a value changes.
    ///
    /// - Parameter impact: The feedback style to trigger.
    static func feedback(hapticImpact style: UIImpactFeedbackGenerator.FeedbackStyle) -> AnyChangeEffect {
        .simulation { change in
            HapticFeedbackEffect(feedback: .impact(style), impulseCount: change)
        }
    }

    /// Triggers haptic feedback to indicate a change in selection whenever a value changes.
    static var feedbackHapticSelection: AnyChangeEffect {
        .simulation { change in
            HapticFeedbackEffect(feedback: .selection, impulseCount: change)
        }
    }
}

internal struct HapticFeedbackEffect: ViewModifier, Simulative {
    var impulseCount: Int = 0

    // TODO: Remove from protocol
    var initialVelocity: CGFloat = 0

    enum FeedbackType {
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case selection
    }

    var feedbackType: FeedbackType

    init(feedback: FeedbackType, impulseCount: Int) {
        self.feedbackType = feedback
        self.impulseCount = impulseCount
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: impulseCount) { _ in
                switch feedbackType {
                case .notification(let type):
                    let generator = UINotificationFeedbackGenerator()

                    generator.notificationOccurred(type)
                case .impact(let style):
                    let generator = UIImpactFeedbackGenerator(style: style)

                    generator.impactOccurred()
                case .selection:
                    let generator = UISelectionFeedbackGenerator()

                    generator.selectionChanged()
                }
            }
    }
}
#endif
