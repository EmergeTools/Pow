import Pow
import SwiftUI

struct SpinExample: View, Example {
    @State
    var changes: Int = 0

    var body: some View {
        ZStack {
            Label {
                Text(changes.formatted())
                    .contentTransition(.identity)
                    .monospacedDigit()
            } icon: {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundStyle(.blue.gradient)
                    .changeEffect(.spin(axis: (0, 1, -0.05), anchor: UnitPoint(x: 0.5, y: 0.5), perspective: 0.6, rate: .fast), value: changes)
            }
            .padding(.vertical, 8)
            .padding(.leading, 16)
            .padding(.trailing, 24)
            .background(.thinMaterial, in: Capsule(style: .continuous))
            .foregroundColor(.primary)
            .font(.system(.title, design: .rounded, weight: .bold))
        }
        .defaultBackground()
        .onTapGesture {
            withAnimation {
                changes += 1
            }
        }
    }

    static var description: some View {
        Text("""
        Spins the view around the given axis when a change happens.

        - Parameters:
            - `axis`: The x, y and z elements that specify the axis of rotation.
            - `anchor`: The location with a default of center that defines a point in 3D space about which the rotation is anchored.
            - `anchorZ`: The location with a default of 0 that defines a point in 3D space about which the rotation is anchored.
            - `perspective`: The relative vanishing point with a default of 1 / 6 for this rotation.
            - `rate`: How fast the the view spins.
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "arrow.clockwise")
    }
}
