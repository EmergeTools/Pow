import Pow
import SwiftUI

struct FilmExposureExample: View, Example {
    @State
    var isVisible: Bool = false

    var body: some View {
        ZStack {
            ZStack {
                // Placeholder
                Rectangle().fill(.black)

                if isVisible {
                    Image("disco")
                        .resizable()
                        .zIndex(1)
                        .transition(.movingParts.filmExposure)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(width: 350, height: 525)
        }
        .defaultBackground()
        .onTapGesture {
            withAnimation(.easeInOut(duration: 1.8)) {
                isVisible.toggle()
            }
        }
        .autotoggle($isVisible, with: .easeInOut(duration: 1.8))
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "film")
    }
}
