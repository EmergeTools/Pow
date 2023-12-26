import SwiftUI
#if os(iOS) && EMG_PREVIEWS
import SnapshotPreferences
#endif

public extension AnyTransition.MovingParts {
    /// A transition that dissolves the view into many small particles.
    ///
    /// The transition is only performed on removal.
    static var vanish: AnyTransition {
        vanish(.tint)
    }

    /// A transition that dissolves the view into many small particles.
    ///
    /// The transition is only performed on removal.
    ///
    /// - Parameter style: The style to use for the particles.
    /// - Parameter increasedBrightness: A Boolean that indicates whether the particles should render with increased brightness. Defaults to `true`.
    ///
    /// - Note: This will use a ease-out animation with a duration of 900ms by default.
    static func vanish<T: ShapeStyle>(_ style: T, increasedBrightness: Bool = true) -> AnyTransition {
        return .asymmetric(
            insertion: .identity,
            removal: .modifier(
                active: Vanish(animatableData: 0, style: style, increasedBrightness: increasedBrightness)
                    .defaultAnimation(Vanish.defaultAnimation),
                identity: Vanish(animatableData: 1, style: style, increasedBrightness: increasedBrightness)
                    .defaultAnimation(Vanish.defaultAnimation)
            )
        )
    }

    /// A transition that dissolves the view into many small particles.
    ///
    /// The transition is only performed on removal.
    ///
    /// - Parameter style: The style to use for the particles.
    /// - Parameter mask: A mask to use to determine which particles are inside the view.
    /// - Parameter eoFill: A Boolean that indicates whether the shape is interpreted with the even-odd winding number rule.
    /// - Parameter increasedBrightness: A Boolean that indicates whether the particles should render with increased brightness. Defaults to `true`.
    ///
    /// - Note: This will use a ease-out animation with a duration of 900ms by default.
    static func vanish<T: ShapeStyle, S: Shape>(_ style: T, mask: S, eoFill: Bool = false, increasedBrightness: Bool = true) -> AnyTransition {
        return .asymmetric(
            insertion: .identity,
            removal: .modifier(
                active: Vanish(animatableData: 0, style: style, mask: mask, eoFill: eoFill, increasedBrightness: increasedBrightness)
                    .defaultAnimation(Vanish.defaultAnimation),
                identity: Vanish(animatableData: 1, style: style, mask: mask, eoFill: eoFill, increasedBrightness: increasedBrightness)
                    .defaultAnimation(Vanish.defaultAnimation)
            )
        )
    }
}

internal struct Vanish: ViewModifier, Animatable, AnimatableModifier {
    static let defaultAnimation: Animation = .easeOut(duration: 0.9)

    var animatableData: CGFloat = 0

    var style: AnyShapeStyle

    var mask: (any Shape)?

    var eoFill: Bool

    var increasedBrightness: Bool

    @Environment(\.colorScheme)
    var colorScheme

    internal init<S: ShapeStyle>(animatableData: CGFloat = 0, style: S, mask: (any Shape)? = nil, eoFill: Bool = true, increasedBrightness: Bool = true) {
        self.animatableData = animatableData
        self.style = AnyShapeStyle(style)
        self.mask = mask
        self.eoFill = eoFill
        self.increasedBrightness = increasedBrightness
    }

    var progress: CGFloat {
        get { animatableData }
        set { animatableData = newValue }
    }

    func body(content: Content) -> some View {
        content
            .opacity(progress != 1 ? 0 : 1)
            .animation(nil, value: progress)
            .overlay {
                Canvas { ctx, size in
                    if progress == 1 { return }

                    let bounds = CGRect(origin: .zero, size: size).insetBy(dx: 28, dy: 28)

                    let particleSize: CGFloat = 12

                    let rows = Int((bounds.width  / particleSize).rounded(.up))
                    let cols = Int((bounds.height / particleSize).rounded(.up))

                    var rng = SeededRandomNumberGenerator(seed: size.width)

                    let path = mask?.path(in: bounds).cgPath

                    for x in 0 ..< rows {
                        for y in 0 ..< cols {
                            let x = CGFloat(x)
                            let y = CGFloat(y)

                            var currentParticleSize = particleSize + .random(in: 0 ... 15, using: &rng)

                            var center = CGPoint(
                                x: bounds.minX + CGFloat(x) * particleSize - particleSize / 2,
                                y: bounds.minY + CGFloat(y) * particleSize - particleSize / 2
                            )

                            guard path?.contains(center, using: eoFill ? .evenOdd : .winding) ?? bounds.contains(center) else {
                                continue
                            }

                            // Center
                            center.x += (currentParticleSize - currentParticleSize * progress) / 2
                            center.y += (currentParticleSize - currentParticleSize * progress) / 2

                            currentParticleSize *= progress

                            let particleRect = CGRect(
                                center: center,
                                size: CGSize(width: currentParticleSize, height: currentParticleSize)
                            )

                            let circle = Circle().path(in: particleRect)

                            let r = fmod((CGFloat(x) / .pi) + (CGFloat(y * y) / .pi), 1)

                            let dX: CGFloat = 6 * particleSize

                            let speedUp: CGFloat = 1// + .random(in: -0.1 ... 0.1, using: &rng)
                            let offsetX: CGFloat = .random(in: -dX / 2 ... dX / 2, using: &rng)
                            let offsetY: CGFloat = .random(in: -dX / 2 ... dX / 2, using: &rng)

                            ctx.drawLayer { ctx in
                                ctx.translateBy(
                                    x: map(value: 1 - (progress / speedUp), inMin: 0, inMax: 1, outMin: 0, outMax: offsetX),
                                    y: map(value: 1 - (progress / speedUp), inMin: 0, inMax: 1, outMin: 0, outMax: offsetY)
                                )

                                ctx.opacity = progress - 0.3 * r

                                ctx.fill(circle, with: .style(style))
                                ctx.addFilter(.blur(radius: 6 * progress))
                                ctx.fill(circle, with: .style(style))
                            }

                        }
                    }
                }
                .blur(radius: 6.0 * easeOut(clamp(progress / 14.0)))
                .brightness(increasedBrightness ? 4.5 * easeOut(clamp(progress / 18.0)) : 0)
                .padding(-25)
                .allowsHitTesting(false)
            }
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Vanish_Previews: PreviewProvider {
    struct Item: Identifiable {
        var color: Color

        let id: UUID = UUID()

        init() {
            color = [Color.red, .orange, .yellow, .green, .purple, .mint].randomElement()!
        }
    }

    struct Preview: View {
        @State
        var items: [Item] = [Item()]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vanish")
                            .bold()

                        Text("myView.transition(\n  **.movingParts.vanish(mask: Capsule())**\n)")
                    }
                        .font(.footnote.monospaced())
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.thickMaterial)
                        )

                    Stepper("Count") {
                        withAnimation {
                            items.append(Item())
                        }
                    } onDecrement: {
                        withAnimation(.linear(duration: 1.2)) {
                            if !items.isEmpty {
                                items.removeLast()
                            }
                        }
                    }

                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible())
                    ]

                    let shape = Capsule()

                    LazyVGrid(columns: columns) {
                        ForEach(items) { item in
                            shape
                                .fill(item.color)
                                .transition(.movingParts.vanish(.white, mask: shape))
                                .aspectRatio(1/1.4, contentMode: .fit)
                                .id(item.id)
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
        .environment(\.colorScheme, .dark)
        #if os(iOS) && EMG_PREVIEWS
          .emergeSnapshotPrecision(0)
        #endif
    }
}
#endif
