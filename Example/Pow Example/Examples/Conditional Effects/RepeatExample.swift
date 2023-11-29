import Pow
import SwiftUI

struct RepeatExample: View, Example {
    @State
    var isEnabled: Bool = false

    var body: some View {
        VStack {
            GroupBox {
                Toggle("Enable Effect", isOn: $isEnabled.animation())
            }
            .padding(.horizontal)

            Spacer()

            Button {

            } label: {
                Label("Accept", systemImage: "phone.fill")
            }
            .tint(.green)
            .disabled(!isEnabled)
            .conditionalEffect(.repeat(.wiggle(rate: .fast), every: .seconds(2)), condition: isEnabled)

            Button {

            } label: {
                Label("Update", systemImage: "sparkles")
            }
            .disabled(!isEnabled)
            .conditionalEffect(.repeat(.shine, every: .seconds(2)), condition: isEnabled)

            Spacer()
        }
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
        .defaultBackground()
        .autotoggle($isEnabled)
    }

    static var description: some View {
        Text("""
        Repeats an `AnyChangeEffect` at regular intervals.

        - `effect`: The effect to repeat.
        - `interval` The candence at which the effect is repeated.
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "arrow.counterclockwise")
    }

    static var newIn0_3_0: Bool { true }
}
