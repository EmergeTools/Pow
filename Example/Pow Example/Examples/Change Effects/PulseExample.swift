import Pow
import SwiftUI

struct PulseExample: View, Example {
    @State
    var changes: Int = 0

    @State
    var drawingMode: AnyChangeEffect.PulseDrawingMode = .fill

    var body: some View {
        VStack {
            GroupBox {
                LabeledContent("Drawing Mode") {
                    Picker("Drawing Mode", selection: $drawingMode) {
                        Text("Fill").tag(AnyChangeEffect.PulseDrawingMode.fill)
                        Text("Stroke").tag(AnyChangeEffect.PulseDrawingMode.stroke)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

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
                                    .changeEffect(.pulse(shape: shape, style: .pink, drawingMode: drawingMode, count: 1), value: changes)
                            }
                            .alignmentGuide(HorizontalAlignment.badgeAlignment) { d in
                                d[HorizontalAlignment.center]
                            }
                            .alignmentGuide(VerticalAlignment.badgeAlignment) { d in
                                d[VerticalAlignment.center]
                            }
                            .allowsHitTesting(false)
                    }
            }

            Spacer()
        }
        .defaultBackground()
        .onTapGesture {
            changes += 1
        }
    }

    static var description: some View {
        Text("""
        Adds one or more shapes that are emitted from the view.

        By default, the shape will be colored in the current tint style.

        - Parameters:
          - `shape`: The shape to use for the effect.
          - `style`: The style to use for the effect.
          - `drawingMode` Changes between filled or stroked shapes. Default is `.fill`.
          - `count`: The number of shapes to emit.
          - `layer` The particle layer to use. Prevents the shape from being clipped by the parent view. (Optional)
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "dot.radiowaves.left.and.right")
    }

    static var newIn0_3_0: Bool { true }
}
