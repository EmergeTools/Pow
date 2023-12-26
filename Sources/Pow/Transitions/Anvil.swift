import SwiftUI
#if os(iOS) && EMG_PREVIEWS
import SnapshotPreferences
#endif

public extension AnyTransition.MovingParts {
    /// A transition that drops the view down from the top.
    ///
    /// The transition is only performed on insertion and takes 1.4 seconds.
    static var anvil: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active:   Anvil(animatableData: 0),
                identity: Anvil(animatableData: 1)
            ),
            removal: .identity
        )
        .animation(.linear(duration: 1.4))
    }
}

internal struct Anvil: ViewModifier, Animatable, AnimatableModifier {
    var animatableData: CGFloat = 0

    #if os(iOS)
    @State
    var feedbackGenerator: UIImpactFeedbackGenerator?
    #endif

    internal init(animatableData: CGFloat = 0) {
        self.animatableData = animatableData
    }

    var progress: CGFloat {
        get { animatableData }
        set { animatableData = newValue }
    }

    func body(content: Content) -> some View {
        /// Fraction of the animation spent on the view falling down.
        let fall: CGFloat = 0.1

        /// Progress of the fall.
        let fallT  = map(value: min(progress, fall), inMin: 0, inMax: fall, outMin: 0, outMax: 1)

        /// Progress of the shake.
        let shakeT = map(value: clamp(fall, progress - 0.01, 2 * fall) - fall, inMin: 0, inMax: fall, outMin: 0, outMax: 1)

        let padding = EdgeInsets(top: 150, leading: 130, bottom: 100, trailing: 130)

        let grayImage: Image = Image("anvil_smoke_gray", bundle: .module)
        let whiteImage: Image = Image("anvil_smoke_white", bundle: .module)

        content
            #if os(iOS)
            .onChange(of: fallT) { newFallT in
                if fallT < 1 && newFallT >= 1 {
                    feedbackGenerator?.impactOccurred()
                    feedbackGenerator = nil
                } else if newFallT > 0 && feedbackGenerator == nil {
                    feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                    feedbackGenerator?.prepare()
                }
            }
            #endif
            .offset(x: 0, y: -400 * (1 - fallT))
            .animation(nil, value: progress)
            .offset(
                x: 2 * sin(shakeT * 3 * .pi) * (1 - shakeT),
                y: 4 * sin(shakeT * 4 * .pi) * (1 - shakeT)
            )
            .overlay {
                Canvas { ctx, size in
                    if progress == 1 { return }

                    var rng = SeededRandomNumberGenerator(seed: size.width)

                    let bounds = CGRect(origin: .zero, size: size).insetBy(dx: 130, dy: 100)

                    do {
                        let resolvedGrayImage = ctx.resolve(grayImage)
                        let resolvedWhiteImage = ctx.resolve(whiteImage)

                        /// Progress of the dust animation.
                        let dustT = map(value: max(0, progress - fall), inMin: 0, inMax: 1 - fall, outMin: 0, outMax: 1)

                        // How far are the particles apart.
                        let particleDistance: CGFloat = 10

                        let particleSize = CGSize(width: 88, height: 88)

                        let rows = Int((bounds.width / particleDistance).rounded(.up))
                        let cols = 2

                        guard rows > 0 else {
                            return
                        }

                        for x in 0 ..< rows {
                            for _ in 0 ..< cols {
                                let x = CGFloat(x)
                                let relativeX = (x / CGFloat(rows - 1))

                                let center = CGPoint(
                                    x: bounds.minX + x * particleDistance + .random(in: -15 ... 15, using: &rng),
                                    y: bounds.maxY + .random(in: -5 ... 5, using: &rng)
                                )

                                let maxOffsetX: CGFloat = particleDistance * 4
                                let maxOffsetY: CGFloat = particleDistance * 2

                                let t = easeOut(dustT)

                                let offsetX = maxOffsetX * (relativeX - 0.5) * 2 * .random(in: 0.8 ... 1.2, using: &rng)
                                let offsetY = CGFloat.random(in: -maxOffsetY / 2 ... maxOffsetY / 2, using: &rng) + (t * t) * -50

                                var scale = 1 + 0.6 * (1 - pow(sin(relativeX * .pi), 0.4)) + .random(in: 0 ... 0.2, using: &rng)
                                scale *= 0.8 + (dustT * 0.2)
                                scale /= 3
                                scale *= 1 - pow(2, -50 * dustT)

                                var rotation = Angle.degrees(180) * .random(in: -1 ... 1, using: &rng)
                                rotation += .degrees(125) * -(relativeX - 0.5) * CGFloat.random(in: 0.5 ... 1, using: &rng) * t * 1.5

                                ctx.drawLayer { ctx in
                                    ctx.translateBy(x: 0, y: -(particleSize.height * scale * 0.9) / 2)

                                    ctx.translateBy(
                                        x: offsetX * t,
                                        y: offsetY * t
                                    )

                                    ctx.translateBy(x: center.x, y: center.y)
                                    ctx.rotate(by: rotation)

                                    ctx.scaleBy(x: scale, y: scale)

                                    ctx.opacity = 0.8 * (1 - 0.5 * abs(relativeX - 0.5)) * (1 - dustT)

                                    if progress >= fall {
                                        if Double(x).truncatingRemainder(dividingBy: 2.0).isZero {
                                            ctx.draw(resolvedWhiteImage, in: CGRect(center: .zero, size: resolvedWhiteImage.size))
                                        } else {
                                            ctx.draw(resolvedGrayImage, in: CGRect(center: .zero, size: resolvedGrayImage.size))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    do {
                        // Progress of the specks animating.
                        let speckT = clamp(map(value: progress, inMin: fall + 0.02, inMax: 1 - 0.2, outMin: 0, outMax: 1))

                        let specks = 20

                        let speckSize = CGSize(width: 1, height: 1)

                        let arc = 1 - pow(2 * speckT - 1, 2)

                        let maxOffsetY = bounds.height * 0.9
                        let maxOffsetX = bounds.width  * 0.6

                        for s in 0 ..< specks {
                            let s = CGFloat(s)

                            let xFrac = (s / CGFloat(specks))

                            var dX = CGFloat.random(in: -maxOffsetX ... maxOffsetX, using: &rng)
                            dX += 60 * (xFrac - 0.5) * 2

                            let dY = CGFloat.random(in: -maxOffsetY ... 0, using: &rng)

                            ctx.drawLayer { ctx in
                                var center = CGPoint(
                                    x: .random(in: bounds.minX ... bounds.maxX, using: &rng),
                                    y: bounds.maxY
                                )

                                center.x += dX * speckT
                                center.y += arc * dY

                                let speckBounds = CGRect(
                                    origin: .zero,
                                    size: speckSize
                                )

                                let speck = Circle().path(in: speckBounds)

                                let scale = CGFloat.random(in: 2 ... 3, using: &rng) * (0.5 + (1 - speckT) / 2)

                                ctx.translateBy(x: center.x, y: center.y)
                                ctx.scaleBy(x: scale, y: scale)

                                ctx.opacity = Double(pow(sin(speckT * .pi), 0.2))
                                ctx.fill(speck, with: .color(Color(white: .random(in: 0.75 ... 0.9, using: &rng))))
                            }
                        }
                    }
                }
                .padding(padding.inverse)
                .allowsHitTesting(false)
            }
    }
}

extension EdgeInsets {
    var inverse: Self {
        EdgeInsets(top: -top, leading: -leading, bottom: -bottom, trailing: -trailing)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Anvil_Previews: PreviewProvider {
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
                        Text("Anvil")
                            .bold()

                        Text("myView.transition(**.movingParts.anvil**)")
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
                        if !items.isEmpty {
                            items.removeLast()
                        }
                    }

                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible())
                    ]

                    LazyVGrid(columns: columns) {
                        ForEach(items) { item in
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(item.color)
                                .transition(.movingParts.anvil)
                                .aspectRatio(1, contentMode: .fit)
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
