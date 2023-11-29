import Pow
import SwiftUI

struct WipeExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    // Assign a random ID so that quick re-insertion will not
                    // play the wipe transition backwards.
                    .id(UUID())
                    .transition(
                        .asymmetric(
                            insertion: .movingParts.wipe(angle: .degrees(235), blurRadius: 30),
                            removal: .movingParts.wipe(angle: .degrees(55), blurRadius: 30)
                        )
                    )
            }
        }
        .defaultBackground()
        .onTapGesture {
            withAnimation(.spring(dampingFraction: 1)) {
                isVisible.toggle()
            }
        }
        .autotoggle($isVisible, with: .spring(dampingFraction: 1))
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "windshield.rear.and.wiper")
    }
}
