import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition that toggles the visibility of the view multiple times
    /// before settling.
    static var flicker: AnyTransition {
        flicker(count: 1)
    }

    /// A transition that toggles the visibility of the view multiple times
    /// before settling.
    ///
    /// - Parameter count: The number of times the visibility is toggled.
    static func flicker(count: Int) -> AnyTransition {
        let count = clamp(1, count, .max)

        return .modifier(
            active:   Flicker(count: count, animatableData: 0),
            identity: Flicker(count: count, animatableData: 1)
        )
    }
}

internal struct Flicker: ViewModifier, ProgressableAnimation, AnimatableModifier, Hashable {
    var count: Int

    var animatableData: CGFloat

    private var isVisible: Bool {
        (progress * CGFloat(count)).remainder(dividingBy: 1) >= 0
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(nil, value: isVisible)
    }
}

#if os(iOS) && DEBUG
struct Flicker_Preview: PreviewableAnimation, PreviewProvider {
  static var animation: Flicker {
    Flicker(count: 1, animatableData: 0)
  }
}

@available(iOS 15.0, *)
struct Flicker_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        @State
        var count: Int = 2

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Flicker")
                            .bold()

                        Text("""
                        myView.transition(
                            .transition(.flicker(count: 2))
                        )
                        """)
                    }
                        .font(.footnote.monospaced())
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.thickMaterial)
                        )

                    Stepper {
                        Text("View Count ") + Text("(\(indices.count))").foregroundColor(.secondary)
                    } onIncrement: {
                        withAnimation {
                            indices.append(UUID())
                        }
                    } onDecrement: {
                        if !indices.isEmpty {
                            let _ = withAnimation {
                                indices.removeLast()
                            }
                        }
                    }

                    Stepper("Flicker Count \(count)", value: $count, in: 1...99)

                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible())
                    ]

                    LazyVGrid(columns: columns) {
                        ForEach(indices, id: \.self) { uuid in
                            ZStack {
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(Color.accentColor)

                                Text("Hello\nWorld!")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(.title, design: .rounded))

                            }
                            .transition(.movingParts.flicker(count: count))
                            .aspectRatio(2, contentMode: .fit)
                            .id(uuid)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    static var previews: some View {
        NavigationView {
            Preview()
                .navigationBarHidden(true)
        }
    }
}
#endif
