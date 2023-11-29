import Pow
import SwiftUI

struct GlareExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    .transition(
                        .asymmetric(
                            insertion: .movingParts.glare(angle: .degrees(225), color: .white),
                            removal: .movingParts.glare(angle: .degrees(45), color: .white)
                                .animation(.movingParts.easeInExponential(duration: 0.9))
                                .combined(with:
                                        .scale(scale: 1.4)
                                        .animation(.movingParts.anticipate(duration: 0.9).delay(0.1))
                                )
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
        Image(systemName: "sun.max")
    }
}
