import Pow
import SwiftUI

struct GlowExample: View, Example {
    @State
    var changes: Int = 0

    var body: some View {
        VStack {
//            GroupBox {
//                LabeledContent("Drawing Mode") {
//                    Picker("Drawing Mode", selection: $drawingMode) {
//                        Text("Fill").tag(AnyChangeEffect.PulseDrawingMode.fill)
//                        Text("Stroke").tag(AnyChangeEffect.PulseDrawingMode.stroke)
//                    }
//                }
//            }
//            .padding(.horizontal)

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
                                    .changeEffect(.glow(color: .pink, radius: 20), value: changes)
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
        Makes the view glow whenever a value changes

        - Parameters:
          - `color`: The color to use.
          - `radius`: The radius of the glow.
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "dot.radiowaves.left.and.right")
    }

    static var newIn0_3_0: Bool { true }
}
