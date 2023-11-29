import Pow
import SwiftUI

struct SwooshExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                PlaceholderView()
                    .transition(.movingParts.swoosh.combined(with: .opacity))
            }
        }
        .defaultBackground()
        .onTapGesture {
            let animation: Animation

            if isVisible {
                animation = .easeIn
            } else {
                animation = .spring()
            }

            withAnimation(animation) {
                isVisible.toggle()
            }
        }
        .autotoggle($isVisible, with: .spring())
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "skew")
    }
}
