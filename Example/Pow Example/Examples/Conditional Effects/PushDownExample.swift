import Pow
import SwiftUI

struct PushDownExample: View, Example {
    @State
    var isPressed: Bool = false

    var body: some View {
        VStack {
            Spacer()

            Text("Push me")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .blendMode(.destinationOut)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor.gradient, in: Capsule(style: .continuous))
                ._onButtonGesture {
                    isPressed = $0
                } perform: {

                }
                .conditionalEffect(.pushDown, condition: isPressed)
                .compositingGroup()
                .padding()

            Spacer()
        }
        .defaultBackground()
    }

    static var description: some View {
        Text("""
        Scales the view down as if pushed wile a condition is met.
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "arrow.down.to.line.compact")
    }

    static var newIn0_3_0: Bool { true }
}
