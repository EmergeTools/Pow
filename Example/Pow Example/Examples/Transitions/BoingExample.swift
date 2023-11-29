import Pow
import SwiftUI

struct BoingExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        HStack {
            if isVisible {
                let defaultSpring = Animation.spring()

                PlaceholderView()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .transition(
                        .asymmetric(
                            insertion: .movingParts.boing(edge: .top).animation(defaultSpring),
                            removal: .movingParts.boing(edge: .top).animation(defaultSpring).combined(with: .opacity.animation(.easeInOut(duration: 0.2)))
                        )
                    )

                let mediumSpring = Animation.interactiveSpring(dampingFraction: 0.5)

                PlaceholderView()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .transition(
                        .asymmetric(
                            insertion: .movingParts.boing(edge: .top).animation(mediumSpring),
                            removal: .movingParts.boing(edge: .top).animation(mediumSpring).combined(with: .opacity.animation(.easeInOut(duration: 0.2)))
                        )
                    )

                let looseSpring = Animation.interpolatingSpring(stiffness: 100, damping: 8)

                PlaceholderView()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .transition(
                        .asymmetric(
                            insertion: .movingParts.boing(edge: .top).animation(looseSpring),
                            removal: .movingParts.boing(edge: .top).animation(looseSpring).combined(with: .opacity.animation(.easeInOut(duration: 0.2)))
                        )
                    )
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
        Image(systemName: "figure.jumprope")
    }
}
