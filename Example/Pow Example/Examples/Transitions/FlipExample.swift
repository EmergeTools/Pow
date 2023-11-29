import Pow
import SwiftUI

struct FlipExample: View, Example {
    enum Variant: Hashable {
        case flip
        case standUp
        case sideways

        var transition: AnyTransition {
            switch self {
            case .flip: return .movingParts.flip
            case .standUp: return .movingParts.rotate3D(.degrees(90), axis: (1, 0, 0), anchor: .bottom, perspective: 1 / 6)
            case .sideways: return .movingParts.rotate3D(.degrees(90), axis: (0, 1, 0), perspective: 1 / 6)
            }
        }
    }

    @State
    var variant: Variant = .flip

    @State
    var isVisible: Bool = false

    var body: some View {
        VStack {
            GroupBox {
                LabeledContent("Configuration") {
                    Picker("Configuration", selection: $variant) {
                        Text("Flip").tag(Variant.flip)
                        Text("Sideways").tag(Variant.sideways)
                        Text("Stand Up").tag(Variant.standUp)
                    }
                }
            }
            .padding(.horizontal)

            VStack {
                if isVisible {
                    PlaceholderView()
                        .id(variant)
                        .transition(variant.transition)
                }
            }
            .frame(maxHeight: .infinity)
            .defaultBackground()
            .onTapGesture {
                withAnimation(animation) {
                    isVisible.toggle()
                }
            }
        }
        .defaultBackground()
        .onChange(of: variant) { _ in
            withAnimation(animation) {
                isVisible.toggle()
            }
        }
        .autotoggle($isVisible, with: animation)
    }

    var animation: Animation {
        if isVisible {
            return .easeIn
        } else {
            return .interactiveSpring(response: 0.4, dampingFraction: 0.4, blendDuration: 2.45)
        }
    }

    static var title: String {
        "Flip & Rotate3D"
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "rotate.3d")
    }
}
