import SwiftUI
#if os(iOS) && EMG_PREVIEWS
import SnapshotPreferences
#endif

public extension AnyTransition.MovingParts {
    /// A transitions that shows the view by combining a diagonal wipe with a
    /// white streak.
    static var glare: AnyTransition {
        glare(angle: .degrees(45))
    }

    /// A transitions that shows the view by combining a wipe with a colored
    /// streak.
    ///
    /// The angle is relative to the current `layoutDirection`, such that 0°
    /// represents sweeping towards the trailing edge on insertion and 90°
    /// represents sweeping towards the bottom edge.
    ///
    /// In this example, the removal of the view is using a glare with an
    /// exponential ease-in curve, combined with a anticipating scale animation,
    /// making for a more dramatic exit.
    ///
    /// ```swift
    /// infoBox
    ///     .transition(
    ///         .asymmetric(
    ///             insertion: .movingParts.glare(angle: .degrees(225)),
    ///             removal: .movingParts.glare(angle: .degrees(45))
    ///                 .animation(.movingParts.easeInExponential(duration: 0.9))
    ///                 .combined(with:
    ///                     .scale(scale: 1.4).animation(.movingParts.anticipate(duration: 0.9).delay(0.1))
    ///                 )
    ///             )
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - direction: The angle of the wipe.
    ///   - color: The color of the glare effect.
    ///   - increasedBrightness: A Boolean that indicates whether the glare is displayed with increased brightness. Defaults to `true`.
    static func glare(angle: Angle, color: Color = .white, increasedBrightness: Bool = true) -> AnyTransition {
        .modifier(
            active:   Glare(angle, color: color, increasedBrightness: increasedBrightness, animatableData: 0),
            identity: Glare(angle, color: color, increasedBrightness: increasedBrightness, animatableData: 1)
        )
    }
}

internal struct Glare: ViewModifier, DebugProgressableAnimation, AnimatableModifier {
    var animatableData: CGFloat = 0

    var angle: Angle

    var color: Color

    var increasedBrightness: Bool

    @Environment(\.layoutDirection)
    var layoutDirection

    internal init(_ angle: Angle, color: Color, increasedBrightness: Bool = true, animatableData: CGFloat = 0) {
        self.animatableData = animatableData
        self.angle = angle
        self.color = color
        self.increasedBrightness = increasedBrightness
    }

    func body(content: Content) -> some View {
        let l = animatableData * 1.6
        let t = animatableData * 1

        let full  = color
        let empty = color.opacity(0)

        content
            .mask {
                GeometryReader { p in
                    let bounds = CGRect(origin: .zero, size: p.size).boundingBox(at: angle)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                stops: [
                                Gradient.Stop(color: .black, location: -1),
                                Gradient.Stop(color: .black, location: l),
                                Gradient.Stop(color: .clear, location: l),
                                Gradient.Stop(color: .clear, location: 2),
                            ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: bounds.width, height: bounds.height)
                        .position(x: bounds.midX, y: bounds.midY)
                        .rotationEffect(angle)
                        .animation(nil, value: animatableData)
                        .animation(nil, value: angle)
                }
            }
            .overlay {
                GeometryReader { p in
                    let bounds = CGRect(origin: .zero, size: p.size).boundingBox(at: angle)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: empty, location: -1),
                                    Gradient.Stop(color: empty, location: t),
                                    Gradient.Stop(color: full,  location: t + 0.01),
                                    Gradient.Stop(color: full,  location: l + 0.01),
                                    Gradient.Stop(color: empty, location: l + 0.02),
                                    Gradient.Stop(color: empty, location: 2),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: bounds.width, height: bounds.height)
                        .position(x: bounds.midX, y: bounds.midY)
                        .rotationEffect(angle)
                        .brightness(increasedBrightness ? 4 * easeInCubic(clamp(1.0 - animatableData)) : 0)
                        .blendMode(.sourceAtop)
                        .allowsHitTesting(false)
                        .animation(nil, value: animatableData)
                        .animation(nil, value: angle)
                }
            }
            .compositingGroup()
    }
}

#if os(iOS) && DEBUG
@available(iOS 16.0, *)
struct Glare_Preview: PreviewableAnimation, PreviewProvider {
  static var animation: Glare {
    Glare(.degrees(45), color: .white, increasedBrightness: true, animatableData: 0)
  }

  static var content: any View {
    Glare_Previews.makeRect(start: .indigo, end: .purple)
        .frame(width: 100, height: 100)
        .preferredColorScheme(.dark)
  }
}

@available(iOS 16.0, *)
struct Glare_Previews: PreviewProvider {
  static func makeRect(start: Color, end: Color) -> some View {
    RoundedRectangle(cornerRadius: 18, style: .continuous)
        .fill(LinearGradient(
          colors: [start, end],
            startPoint: .topLeading,
            endPoint: .bottom
        ))
        .compositingGroup()
        .overlay {
            Text("Hello\nWorld")
                .foregroundStyle(.white.shadow(.inner(radius: 0.5)))
        }
        .font(.system(.largeTitle, design: .rounded).weight(.medium))
        .multilineTextAlignment(.center)
  }

    struct Item: Identifiable {
        var color1: Color
        var color2: Color

        let id: UUID = UUID()

        init() {
            let color1: Color = [.indigo, .purple, .pink].randomElement()!

            self.color1 = color1
            self.color2 = [.indigo, .purple, .pink].filter {
                $0 != color1
            }.randomElement()!
        }
    }

    struct Preview: View {
        @State
        var items: [Item] = [Item()]

        @State
        var angle: Angle = .degrees(45)

        @State
        var isRightToLeft: Bool = false

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Glare")
                            .bold()

                        Text("myView.transition(**.movingParts.glare**)")
                    }
                    .font(.footnote.monospaced())
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.thickMaterial)
                    )

                    Stepper {
                        (Text("View Count ") + Text("(\(items.count))").foregroundColor(.secondary))
                            .animation(nil, value: items.count)
                    } onIncrement: {
                        withAnimation {
                            items.append(Item())
                        }
                    } onDecrement: {
                        withAnimation {
                            if !items.isEmpty {
                                items.removeLast()
                            }
                        }
                    }

                    Toggle("Right To Left", isOn: $isRightToLeft)

                    LabeledContent("Angle") {
                        AngleControl(angle: $angle)
                    }

                    LabeledContent("Reference") {
                        Image(systemName: "arrow.forward.circle")
                            .imageScale(.large)
                            .rotationEffect(angle)
                            .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
                    }

                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible()),
                    ]

                    LazyVGrid(columns: columns) {
                        ForEach(items.indices, id: \.self) { index in
                            let item = items[index]

                            Glare_Previews.makeRect(start: item.color1, end: item.color2)
                                .transition(
                                    .asymmetric(
                                        insertion: .movingParts.glare(angle: angle),
                                        removal: .movingParts.glare(angle: angle)
                                            .animation(.movingParts.easeInExponential(duration: 0.9))
                                            .combined(with:
                                                .scale(scale: 1.4).animation(.movingParts.anticipate(duration: 0.9).delay(0.1))
                                            )
                                        )
                                )
                                .aspectRatio(1, contentMode: .fit)
                                .id(item.id)
                                .zIndex(Double(index))
                        }
                    }
                    .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }

    static var previews: some View {
        NavigationView {
            Preview()
                .navigationBarHidden(true)
        }
        .environment(\.colorScheme, .dark)
        #if os(iOS) && EMG_PREVIEWS
          .emergeSnapshotPrecision(0)
        #endif
    }
}
#endif
