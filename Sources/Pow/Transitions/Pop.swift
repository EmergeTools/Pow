import SwiftUI
import simd

public extension AnyTransition.MovingParts {
    /// A transition that shows a view with a ripple effect and a flurry of
    /// tint-colored particles.
    ///
    /// The transition is only performed on insertion and takes 1.2 seconds.
    static var pop: AnyTransition {
        pop(.tint)
    }

    /// A transition that shows a view with a ripple effect and a flurry of
    /// colored particles.
    ///
    /// In this example, the star uses the pop effect only when transitioning
    /// from `starred == false` to `starred == true`:
    ///
    /// ```swift
    /// Button {
    ///     starred.toggle()
    /// } label: {
    ///     if starred {
    ///         Image(systemName: "star.fill")
    ///             .foregroundStyle(.orange)
    ///             .transition(.movingParts.pop(.orange))
    ///     } else {
    ///         Image(systemName: "star")
    ///             .foregroundStyle(.gray)
    ///             .transition(.identity)
    ///     }
    /// }
    /// ```
    ///
    /// The transition is only performed on insertion.
    ///
    /// - Parameter style: The style to use for the effect.
    static func pop<S: ShapeStyle>(_ style: S) -> AnyTransition {
        let pop = AnyTransition
            .modifier(
                active:   Pop(style: AnyShapeStyle(style), animatableData: 0),
                identity: Pop(style: AnyShapeStyle(style), animatableData: 1)
            )
            .animation(.linear(duration: 1.2))

        return .asymmetric(
            insertion: pop,
            removal: .identity
        )
    }
}

@available(iOS 15.0, *)
struct Pop: AnimatableModifier, ProgressableAnimation, ViewModifier {
    var animatableData: CGFloat = 0

    var style: AnyShapeStyle

    var seed: CGFloat = .random(in: 0 ... 255)

    init(style: AnyShapeStyle, animatableData: CGFloat) {
        self.animatableData = animatableData
        self.style = style
    }

    func body(content: Content) -> some View {
        let t = clamp(2 * (progress - 1/2.5))

        content
            .scaleEffect(1 - pow(2, -20 * t))
            .overlay {
                circleOverlay
            }
            .background {
                particles
            }
            .animation(nil, value: progress)
    }

    @ViewBuilder
    var particles: some View {
        let t = clamp(2 * (progress - 1/3))

        var rng = SeededRandomNumberGenerator(seed: seed)

        Canvas { ctx, size in
            if t == 0 { return }

            let particleSize = CGSize(width: 3, height: 3)

            let particleCount = 20

            let radius: CGFloat = min(size.width, size.height) - 22

            for p in 0 ..< particleCount {
                let f: CGFloat = CGFloat.random(in: 0.95 ... 1.1, using: &rng)

                let particleT = clamp(f * (t - (1 - 1/f)))

                if particleT <= 0 { return }

                let particleOpacity: CGFloat = {
                    if particleT < 0.5 {
                        return 1 - pow(2, -20 * particleT)
                    } else {
                        return 1 - pow(2, 10 * (particleT - 1))
                    }
                }()

                if particleOpacity <= 0 { return }

                let p: CGFloat     = CGFloat(p)
                let pFrac: CGFloat = p / CGFloat(particleCount)

                let yOffset = CGFloat.random(in: -2 ... 2, using: &rng)

                let scale = easeOut(1 - particleT) * CGFloat.random(in: 0.8 ... 1.4, using: &rng)

                ctx.drawLayer { ctx in
                    ctx.translateBy(x: size.width / 2, y: size.height / 2)

                    ctx.rotate(by: .degrees(360 * pFrac + CGFloat.random(in: -5 ... 5, using: &rng)))
                    ctx.translateBy(
                        x: 0,
                        y: lerp(easeOut(particleT), outMin: 0, outMax: radius / 2 + yOffset)
                    )
                    ctx.scaleBy(x: scale, y: scale)

                    ctx.opacity = clamp(particleOpacity)

                    ctx.addFilter(.hueRotation(.degrees(.random(in: -25 ... 25, using: &rng))))

                    let c = Circle().path(in: CGRect(center: .zero, size: particleSize))
                    ctx.fill(c, with: .style(style))
                }
            }
        }
        .padding(-30)
        .aspectRatio(1, contentMode: .fit)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    var circleOverlay: some View {
        let t1 = clamp(1.5 * progress)
        let t2 = clamp(1.5 * (progress - 0.15))

        ZStack {
            Circle()
                .fill(AnyShapeStyle(style))
                .scaleEffect(1 - pow(2, -14 * t1))

            Circle()
                .foregroundColor(.white)
                .scaleEffect(1 - pow(2, -14 * t2))
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .opacity(
            clamp(1 - pow(1.3, -20 * Double(1 - t1)))
        )
        .padding(-8)
        .allowsHitTesting(false)
    }
}

#if os(iOS) && DEBUG
struct Pop_Preview: PreviewableAnimation, PreviewProvider {
  static var animation: Pop {
    Pop(style: AnyShapeStyle(.tint), animatableData: 0)
  }

  static var content: any View {
    Image(systemName: "heart.fill")
        .foregroundColor(.red)
        .tint(.red)
        .preferredColorScheme(.dark)
  }
}

@available(iOS 15.0, *)
struct Pop_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var favorited = false

        @State
        var starred = false

        @State
        var commented = false

        @State
        var leaf = false

        @State
        var count = 0

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pop")
                            .bold()

                        Text("myView.transition(.movingParts.pop(.red))").padding(.trailing, -8)
                    }
                    .font(.footnote.monospaced())
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.thickMaterial)
                    )

                    HStack(alignment: .top) {
                        Circle()
                            .fill(.blue)
                            .overlay {
                                Text("RB").font(.system(size: 20, design: .rounded))
                            }
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("robb")
                                Text("@DLX").foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                            .layoutPriority(1)
                            .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)


                            Text("Trying out button state transitions in SwiftUI.")

                            HStack(spacing: 24) {
                                Button {
                                    withAnimation {
                                        favorited.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        Group {
                                            if favorited {
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.red)
                                                    .transition(.movingParts.pop)
                                            } else {
                                                Image(systemName: "heart")
                                                    .foregroundColor(.gray)
                                                    .transition(.identity)
                                            }
                                        }

                                        Text((favorited ? 144 : 143).formatted())
                                            .foregroundColor(favorited ? .red : .gray)
                                    }
                                }
                                .tint(.red)

                                Button {
                                    withAnimation {
                                        starred.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        Group {
                                            if starred {
                                                Image(systemName: "star.fill")
                                                    .foregroundStyle(.tint)
                                                    .transition(.movingParts.pop)
                                            } else {
                                                Image(systemName: "star")
                                                    .foregroundColor(.gray)
                                                    .transition(.identity)
                                            }
                                        }

                                        Text((starred ? 80 : 79).formatted())
                                            .foregroundColor(starred ? .orange : .gray)
                                    }
                                }
                                .tint(.orange)

                                Button {
                                    withAnimation {
                                        commented.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        Group {
                                            if commented {
                                                Image(systemName: "bubble.right.fill")
                                                    .foregroundStyle(.tint)
                                                    .transition(.movingParts.pop)
                                            } else {
                                                Image(systemName: "bubble.right")
                                                    .foregroundColor(.gray)
                                                    .transition(.identity)
                                            }
                                        }

                                        Text((commented ? 3 : 2).formatted())
                                            .foregroundColor(commented ? .blue : .gray)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.top, 4)
                            .imageScale(.large)
                            .font(.footnote.monospacedDigit().weight(.medium))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.thickMaterial)
                    )

                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.plain)
        }
    }

    static var previews: some View {
        NavigationView {
            Preview()
                .navigationBarHidden(true)
        }
        .environment(\.colorScheme, .dark)
    }
}
#endif
