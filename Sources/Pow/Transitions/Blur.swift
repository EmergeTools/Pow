import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition from blurry to sharp on insertion, and from sharp to blurry
    /// on removal.
    static var blur: AnyTransition {
        .modifier(
            active:   Blur(radius: 30),
            identity: Blur(radius: 0)
        )
    }

    /// A transition from blurry to sharp on insertion, and from sharp to blurry
    /// on removal.
    ///
    /// - Parameter radius: The radial size of the blur at the end of the transition.
    static func blur(radius: CGFloat) -> AnyTransition {
        .modifier(
            active:   Blur(radius: radius),
            identity: Blur(radius: 0)
        )
    }
}

internal struct Blur: ViewModifier, Animatable, AnimatableModifier, Hashable {
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .blur(radius: radius)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Blur_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        @State
        var radius: CGFloat = 30

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Flip")
                            .bold()

                        Text("""
                        myView.transition(
                            .transition(.flip)
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

                    if #available(iOS 16.0, *) {
                        LabeledContent {
                            Slider(value: $radius, in: 0.0...100.0)
                                .frame(width: 150)
                        } label: {
                            Text("Radius: \(radius, format: .number.precision(.fractionLength(0)))")
                        }
                    }

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
                            .transition(.movingParts.blur(radius: radius).combined(with: .opacity))
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
