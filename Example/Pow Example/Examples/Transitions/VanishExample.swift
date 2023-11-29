import Pow
import SwiftUI

struct VanishExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                Circle()
                    .frame(width: 250, height: 250)
                    // Assign a random ID so that quick re-insertion will not
                    // play the vanish transition backwards.
                    .id(UUID())
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .movingParts.vanish(Color(white: 0.8), mask: Circle())
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
        Image(systemName: "circle.dotted")
    }
}
