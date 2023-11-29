import Pow
import SwiftUI

struct BlurExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    .transition(.movingParts.blur.combined(with: .opacity))
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
        Image(systemName: "drop")
    }
}
