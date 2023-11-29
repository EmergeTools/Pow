import Pow
import SwiftUI

struct SkidExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        VStack {
            if isVisible {
                let overshoot = Animation.movingParts.overshoot(duration: 0.8)

                PlaceholderView()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .transition(.movingParts.skid(direction: .leading).animation(overshoot))

                let mediumSpring = Animation.interactiveSpring(dampingFraction: 0.5)

                PlaceholderView()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .transition(.movingParts.skid.animation(mediumSpring))

                let looseSpring = Animation.interpolatingSpring(stiffness: 100, damping: 8)

                PlaceholderView()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .transition(.movingParts.skid.animation(looseSpring))
            }
        }
        .defaultBackground()
        .onTapGesture {
            withAnimation {
                isVisible.toggle()
            }
        }
        .autotoggle($isVisible)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "arrow.left.and.right.square")
    }
}
