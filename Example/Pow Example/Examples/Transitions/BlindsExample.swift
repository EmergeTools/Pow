import Pow
import SwiftUI

struct BlindsExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    .transition(.movingParts.blinds)
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
        Image(systemName: "blinds.horizontal.open")
    }
}
