import Pow
import SwiftUI

struct PoofExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    .compositingGroup()
                    // Assign a random ID so that quick re-insertion will not
                    // play the poof transition backwards.
                    .id(UUID())
                    .transition(
                        .asymmetric(insertion: .opacity, removal: .movingParts.poof)
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
        Image(systemName: "trash")
    }
}
