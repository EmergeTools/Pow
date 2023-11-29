import Pow
import SwiftUI

struct PingExample: View, Example {
    @State
    var changes: Int = 0

    var body: some View {
        ZStack {
            PlaceholderView()
                .overlay(alignment: .badgeAlignment) {
                    let shape = Capsule()

                    Text(changes.formatted())
                        .font(.body.bold().monospacedDigit())
                        .foregroundColor(.white)
                        .padding(.vertical,   8)
                        .padding(.horizontal, 16)
                        .background {
                            shape.fill(.pink)
                                .changeEffect(.pulse(shape: shape, style: .pink, count: 3), value: changes)
                        }
                        .alignmentGuide(HorizontalAlignment.badgeAlignment) { d in
                            d[HorizontalAlignment.center]
                        }
                        .alignmentGuide(VerticalAlignment.badgeAlignment) { d in
                            d[VerticalAlignment.center]
                        }
                }
        }
        .defaultBackground()
        .onTapGesture {
            changes += 1
        }
    }

    static var description: some View {
        Text("""
        Adds one or more shapes that slowly grow and fade-out behind the view.

        The shape will be colored by the current tint style.

        -Parameters:
          - `shape`: The shape to use for the effect.
          - `style`: The style to use for the effect.
          - `count`: The number of shapes to emit.
        """)
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "dot.radiowaves.left.and.right")
    }
}

extension VerticalAlignment {
    struct BadgeAlignmentID: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.top]
        }
    }

    static let badgeAlignment = VerticalAlignment(BadgeAlignmentID.self)
}

extension HorizontalAlignment {
    struct BadgeAlignmentID: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.trailing]
        }
    }

    static let badgeAlignment = HorizontalAlignment(BadgeAlignmentID.self)
}

extension Alignment {
    static let badgeAlignment = Alignment(horizontal: .badgeAlignment, vertical: .badgeAlignment)
}
