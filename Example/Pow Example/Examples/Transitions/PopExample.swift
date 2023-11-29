import Pow
import SwiftUI

struct PopExample: View, Example {
    @State
    var isFavorited: Bool = false

    var body: some View {
        ZStack {
            HStack {
                if isFavorited {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .transition(
                            .movingParts.pop(.red)
                        )
                } else {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .transition(.identity)
                }

                let favoriteCount = isFavorited ? 143 : 142

                Text(favoriteCount.formatted())
                    .foregroundColor(isFavorited ? .red : .gray)
                    .animation(isFavorited ? .default.delay(0.4) : nil, value: isFavorited)
            }
        }
        .defaultBackground()
        .onTapGesture {
            withAnimation(.spring(dampingFraction: 1)) {
                isFavorited.toggle()
            }
        }
        .autotoggle($isFavorited, with: .spring(dampingFraction: 1))
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "rays")
    }
}
