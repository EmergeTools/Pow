import SwiftUI
import simd

#if os(iOS)
import CoreHaptics
#endif

public extension AnyChangeEffect {
    /// An effect that emits multiple particles in different shades and sizes moving up from the origin point.
    ///
    /// - Parameters:
    ///   - origin: The origin of the particles.
    ///   - layer: The `ParticleLayer` on which to render the effect, default is `local`.
    ///   - particles: The particles to emit.
    static func spray(origin: UnitPoint = .center, layer: ParticleLayer = .local, @ViewBuilder _ particles: () -> some View) -> AnyChangeEffect {
        let particles = particles()
        return .simulation({ change in
            SpraySimulation(view: particles, impulseCount: change, origin: origin, layer: layer)
        })
    }
}

internal struct SpraySimulation<ParticleView: View>: ViewModifier, Simulative {
    var particle: ParticleView

    var impulseCount: Int = 0

    var initialVelocity: CGFloat = 0.0

    var origin: UnitPoint

    private let spring = Spring(zeta: 1, stiffness: 30)

    private struct Ping: Identifiable {
        let id: UUID
        var progress: Float
        var velocity: Float
        var target: Float
    }

    @State
    private var pings: [Ping] = []

    private let layer: ParticleLayer
    
    @Environment(\.particleLayerNames)
    var particleLayerNames

    init(view: ParticleView, impulseCount: Int, initialVelocity: CGFloat = 0.0, origin: UnitPoint = .center, layer: ParticleLayer) {
        self.particle = view
        self.impulseCount = impulseCount
        self.initialVelocity = initialVelocity
        self.origin = origin
        self.layer = layer
    }

    private var isSimulationPaused: Bool {
        pings.isEmpty
    }

    private struct _ViewContainer: SwiftUI._VariadicView.MultiViewRoot {
        func body(children: _VariadicView.Children) -> some View {
            ForEach(Array(zip(0..., children)), id: \.1.id) { offset, child in
                child.tag(offset)
            }
        }
    }

    func body(content: Content) -> some View {
        let hasParticleLayer: Bool = {
            if let name = layer.name, particleLayerNames.contains(name) {
                return true
            } else {
                return false
            }
        }()

        let overlay = TimelineView(.animation(paused: isSimulationPaused)) { context in
            let insets = EdgeInsets(top: 320, leading: 160, bottom: 40, trailing: 160)

            Canvas { context, size in
                var symbols: [GraphicsContext.ResolvedSymbol] = []

                var i = 0
                var nextSymbol: GraphicsContext.ResolvedSymbol? = context.resolveSymbol(id: i)
                while let symbol = nextSymbol {
                    symbols.append(symbol)
                    i += 1
                    nextSymbol = context.resolveSymbol(id: i)
                }

                guard let symbol = symbols.first else { return }

                let symbolWidth  = clamp(0, symbol.size.width,  size.width  / 6)
                let symbolHeight = clamp(0, symbol.size.height, size.height / 8)

                context.translateBy(x: size.width / 2, y: insets.top + (size.height - insets.top - insets.bottom) / 2)

                let indices: SIMD16<Float>       = SIMD16<Float>(stride(from: 0.0, to: 16, by: 1))
                let scaleFactors: SIMD16<Float>  = SIMD16<Float>(stride(from: 0.0, to: 16, by: 1).map { (f: Float) in
                    f.truncatingRemainder(dividingBy: 5.0) / 5.0
                })
                let value: SIMD16<Float>         = indices / 10

                /// To simply the expression :rolleyes:
                let adjustedValue: SIMD16<Float> = (value - 0.5)

                // in degrees
                let angles: SIMD16<Float>     = value * 45 - 45 / 2.0

                for ping in pings {
                    var rng = SeededRandomNumberGenerator(seed: ping.id)

                    let symbolOffset = (0...10).randomElement(using: &rng) ?? 0

                    let value2: SIMD16<Float>  = SIMD16<Float>.random(in: 0.0 ... 1.0, using: &rng) + scaleFactors

                    let insetAmount: Float = cos(ping.progress) * pow(ping.progress, 1) * -Float(symbolHeight) * 2.5

                    let phases: SIMD16<Float>     = (ping.progress * 0.75) + value2
                    let sineScales: SIMD16<Float> = simd_abs(sin(phases * SIMD16(repeating: .pi)))
                    let scales: SIMD16<Float>     = sineScales * (1.0 - pow(ping.progress, 8.0)) * pow(ping.progress, 0.25)

                    let brightness: SIMD16<Float> = .random(in: -0.1 ... 0.1, using: &rng)

                    let x: SIMD16<Float> = adjustedValue * (sin(ping.progress * Float.pi) * Float(symbolWidth) * -2)
                    let y: SIMD16<Float> = insetAmount - (value2 * ping.progress) * Float(symbolHeight) * 2.5

                    for i in 0...10 {
                        let point = CGPoint(x: x[i], y: y[i])

                        let angle = Angle(degrees: angles[i])
                        let scale = Double(scales[i])

                        let symbol = symbols[(i + symbolOffset) % symbols.count]

                        // If we're drawing in the particle group, fade in the
                        // the particles as we're no longer drawing behind the
                        // view.
                        if hasParticleLayer {
                            context.opacity = clamp(Double(ping.progress) * 4)
                        }

                        context.drawLayer { context in
                            context.addFilter(.brightness(Double(brightness[i])))

                            context.rotate(by: .degrees(Double(ping.progress) * -angle.degrees + -angle.degrees * 0.25))
                            context.translateBy(x: point.x, y: point.y)
                            context.scaleBy(x: scale, y: scale)
                            context.rotate(by: .degrees(sqrt(Double(ping.progress) * 2) * angle.degrees - angle.degrees * 0.25))
                            context.draw(symbol, at: .zero)
                        }
                    }
                }
            } symbols: {
                SwiftUI._VariadicView.Tree(_ViewContainer()) {
                    particle
                }
            }
            .padding(insets.inverse)
            .modifier(RelativeOffsetModifier(anchor: origin))
            .allowsHitTesting(false)
            .onChange(of: context.date) { (newValue: Date) in
                let duration = Double(newValue.timeIntervalSince(context.date))
                withAnimation(nil) {
                    update(max(0, min(duration, 1 / 30)))
                }
            }
        }

        content
            .particleLayerBackground(layer: layer, isEnabled: !isSimulationPaused) {
                overlay
            }
            .usesCustomHaptics()
            .onChange(of: impulseCount) { newValue in
                let ping = Ping(
                    id: UUID(),
                    progress: 0,
                    velocity: Float(initialVelocity),
                    target: 1.0
                )

                withAnimation(nil) {
                    pings.append(ping)
                }

                #if os(iOS)
                if let hapticPattern {
                    Haptics.play(hapticPattern)
                }
                #endif
            }
    }

    private func update(_ step: Double) {
        for index in pings.indices {
            var ping = pings[index]

            if spring.response > 0 {
                let (newValue, newVelocity) = spring.value(
                    from: ping.progress,
                    to: ping.target,
                    velocity: ping.velocity,
                    timestep: step
                )
                ping.progress = newValue
                ping.velocity = newVelocity
            } else {
                ping.progress = ping.target
                ping.velocity = .zero
            }

            pings[index] = ping
        }

        pings.removeAll { ping in
            abs(ping.progress - ping.target) < 0.04 && ping.velocity < 0.04
        }
    }

    #if os(iOS)
    private var hapticPattern: CHHapticPattern? {
        var rng = SeededRandomNumberGenerator(seed: 123)

        return try? CHHapticPattern(
            events: (0 ..< 5).map { i in
                let i = Float(i)

                let relativeTime: TimeInterval

                if i == 0 {
                    relativeTime = 0
                } else {
                    relativeTime = Double(i * 0.03) + .random(in: -0.005 ... 0.005, using: &rng)
                }

                return CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6 * (i / 5) + .random(in: -0.2 ... 0.2, using: &rng)),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: relativeTime,
                    duration: 0.05
                )
            },
            parameterCurves: []
        )
    }
    #endif
}

private struct RelativeOffsetModifier: GeometryEffect {
    var anchor: UnitPoint

    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = size.width  * (-0.5 + anchor.x)
        let y = size.height * (-0.5 + anchor.y)

        return ProjectionTransform(
            CGAffineTransform(translationX: x, y: y)
        )
    }
}

private extension CGPoint {
    init(x: Float, y: Float) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
}

private extension Angle {
    init(degrees: Float) {
        self.init(degrees: Double(degrees))
    }
}

#if os(iOS) && DEBUG
struct SprayChangeEffect_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var likesLarge: Int = 352

        @State
        var spells: Int = 139

        @State
        var stars: Int = 953

        @State
        var claps: Int = 238

        @State
        var plus1s: Int = 574

        var body: some View {
            VStack {
                GroupBox {
                    Button {
                        likesLarge += 1
                    } label: {
                        HStack {
                            Image(systemName: "dice.fill")
                                .rotationEffect(.degrees(-15))
                            Text(likesLarge.formatted())
                        }
                        .font(.largeTitle)
                    }
                    .buttonStyle(.bordered)
                    .changeEffect(.spray(origin: UnitPoint(x: 0.25, y: 0.25), {
                        Group {
                            Image(systemName: "suit.heart.fill").foregroundColor(.red)
                            Image(systemName: "suit.club.fill").foregroundColor(.black)
                            Image(systemName: "suit.spade.fill").foregroundColor(.black)
                            Image(systemName: "suit.diamond.fill").foregroundColor(.red)
                        }
                        .font(.largeTitle)
                    }), value: likesLarge)
                    .tint(.green)
                    .frame(maxWidth: .infinity, maxHeight: 240, alignment: .bottom)
                }

                HStack {
                    GroupBox {
                        let particle = Image(systemName: "sparkle").foregroundColor(.purple)

                        Button {
                            spells += 1
                        } label: {
                            HStack {
                                Image(systemName: "wand.and.stars")

                                Text("\(spells, format: .number)")
                            }
                        }
                        .changeEffect(.spray(origin: UnitPoint(x: 0.25, y: 0.5)) { particle }, value: spells)
                        .buttonStyle(.bordered)
                        .tint(.purple)
                        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .bottom)
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .environment(\.locale, .init(identifier: "ar_EG"))

                    GroupBox {
                        Button {
                            stars += 1
                        } label: {
                            Image(systemName: "star.fill")
                                .changeEffect(.spray({ Image(systemName: "star.fill") }), value: stars)
                            Text(stars.formatted())
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .bottom)
                    }
                }

                HStack {
                    GroupBox {
                        Button {
                            claps += 1
                        } label: {
                            Image(systemName: "hands.clap.fill")
                                .changeEffect(.spray({ Image(systemName: "person") }).delay(1), value: claps)
                                .changeEffect(.spray({ Image(systemName: "rays") }).delay(0), value: claps)
                            Text(claps.formatted())
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .bottom)
                    }

                    GroupBox {
                        Button {
                            plus1s += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .changeEffect(.spray({ Image(systemName: "plus") }), value: plus1s)
                            Text(plus1s.formatted())
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .bottom)
                    }
                }
            }
            .monospacedDigit()
            .padding()
        }
    }

    struct ListPreview: View {
        @State
        var claps: [Int: Int] = [:]

        var body: some View {
            NavigationView {
                List {
                    Section("Unclipped") {
                        ForEach(0 ..< 5) { i in
                            HStack {
                                Text("Cell #\(i)")
                                Spacer()

                                Button {
                                    claps[i, default: 0] += 1
                                } label: {
                                    Label(claps[i, default: 0].formatted(), systemImage: "heart.fill")
                                }
                                .monospacedDigit()
                                .controlSize(.small)
                                .buttonBorderShape(.capsule)
                                .changeEffect(.spray(layer: .named("root")) {
                                    Image(systemName: "heart.fill").foregroundStyle(.tint)
                                        .tint(.pink)
                                }, value: claps[i, default: 0])
                            }
                        }
                    }

                    Section("Clipped") {
                        ForEach(0 ..< 5) { i in
                            HStack {
                                Text("Cell #\(i)")
                                Spacer()

                                Button {
                                    claps[i, default: 0] += 1
                                } label: {
                                    Label(claps[i, default: 0].formatted(), systemImage: "heart.fill")
                                }
                                .monospacedDigit()
                                .controlSize(.small)
                                .buttonBorderShape(.capsule)
                                .changeEffect(.spray {
                                    Image(systemName: "heart.fill").foregroundStyle(.tint)
                                        .tint(.pink)
                                }, value: claps[i, default: 0])
                            }
                        }
                    }
                }
                .labelStyle(.titleOnly)
                .buttonStyle(.borderedProminent)
                .navigationTitle("Cells")
            }
            .particleLayer(name: "root")
        }
    }

    static var previews: some View {
        Preview()

        ListPreview()
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Escaping List")
    }
}
#endif
