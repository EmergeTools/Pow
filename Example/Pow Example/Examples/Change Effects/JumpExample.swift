import Pow
import SwiftUI

struct JumpExample: View, Example {
    @State
    var changes: Int = 0

    var body: some View {
        ZStack {
            PlaceholderView()
                .changeEffect(.jump(height: 40), value: changes)
        }
        .defaultBackground()
        .onTapGesture {
            changes += 1
        }
    }

    static var description: some View {
        Text("""
        Makes the view jump the given height and then bounces a few times before settling.

        - `height`: The height of the jump.
        """)
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "figure.jumprope")
    }
}
