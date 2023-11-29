import Pow
import SwiftUI

struct SmokeExample: View, Example {
    @State
    var isEnabled: Bool = false

    var body: some View {
        VStack {
            GroupBox {
                Toggle("Enable Effect", isOn: $isEnabled.animation())
            }
            .padding(.horizontal)

            Spacer()

            ZStack {
                Circle()
                    .fill(.orange.gradient)
                    .brightness(-0.1)

                Rectangle()
                    .fill(.white.gradient)
                    .mask {
                        ZStack {
                            Circle()
                                .strokeBorder(.white.opacity(0.8).gradient, lineWidth: 4)
                                .padding(6)

                            Image(systemName: "opticaldiscdrive.fill")
                                .imageScale(.large)
                                .font(.system(size: 40, weight: .black))
                                .offset(y: -2)
                        }
                    }
                    .blendMode(.lighten)
            }
            .compositingGroup()
            .drawingGroup()
            .frame(width: 120, height: 120)
            .grayscale(isEnabled ? 0 : 1)
            .conditionalEffect(.smoke(layer: .named("root")), condition: isEnabled)

            Spacer()

        }
        .defaultBackground()
        .autotoggle($isEnabled)
    }

    static var description: some View {
        Text("""
        Emmits smoke from behind the view.

        - `layer` The particle layer to use. Prevents the smoke from being clipped by the parent view. (Optional)
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "flame")
    }

    static var newIn0_3_0: Bool { true }
}
