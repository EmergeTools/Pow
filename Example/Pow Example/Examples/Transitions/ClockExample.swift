import Pow
import SwiftUI

struct ClockExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    .transition(.movingParts.clock(blurRadius: 10))
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
        Image(systemName: "clock")
    }
}
