import SwiftUI

public extension AnyChangeEffect {
    /// An effect that emits the provided particles from the origin point and slowly float up while moving side to side.
    ///
    /// This effect respects `particleLayer()`.
    ///
    /// - Parameters:
    ///   - origin: The origin of the particle.
    ///   - layer: The `ParticleLayer` on which to render the effect, default is `local`.
    ///   - particles: The particles to emit.
    static func rise(origin: UnitPoint = .center, layer: ParticleLayer = .local, @ViewBuilder _ particles: () -> some View) -> AnyChangeEffect {
        let particles = particles()
        return .simulation { change in
            RisingParticleSimulation(origin: origin, particles: particles, impulseCount: change, layer: layer)
        }
    }

    /// An effect that emits the provided particle from the origin point and slowly float up while moving side to side.
    ///
    /// - Parameters:
    ///   - origin: The origin of the particle.
    ///   - particle: The particle to emit.
    @available(*, deprecated, renamed: "rise(origin:_:)")
    static func risingParticle(origin: UnitPoint = .center, @ViewBuilder _ particle: () -> some View) -> AnyChangeEffect {
        rise(origin: origin, particle)
    }
}

internal struct RisingParticleSimulation<ParticlesView: View>: ViewModifier, Simulative {
    var origin: UnitPoint

    var particles: ParticlesView

    var impulseCount: Int = 0

    var initialVelocity: CGFloat = 0.0

    private let spring = Spring(zeta: 1, stiffness: 30)

    private struct Item: Identifiable {
        let id: UUID
        var progress: CGFloat
        var velocity: CGFloat
        var change: Int
    }

    @State
    private var items: [Item] = []

    private let target: CGFloat = 1.0

    private let layer: ParticleLayer

    private var isSimulationPaused: Bool {
        items.isEmpty
    }

    internal init(origin: UnitPoint, particles: ParticlesView, impulseCount: Int = 0, layer: ParticleLayer) {
        self.origin = origin
        self.particles = particles
        self.impulseCount = impulseCount
        self.layer = layer
    }

    private struct _ViewContainer: SwiftUI._VariadicView.MultiViewRoot {
        func body(children: _VariadicView.Children) -> some View {
            ForEach(Array(zip(0..., children)), id: \.1.id) { offset, child in
                child.tag(offset)
            }
        }
    }

    func body(content: Content) -> some View {
        let overlay = TimelineView(.animation(paused: isSimulationPaused)) { context in
            let insets = EdgeInsets(top: 80, leading: 40, bottom: 20, trailing: 40)

            Canvas { context, size in
                var symbols: [GraphicsContext.ResolvedSymbol] = []

                var i = 0
                var nextSymbol: GraphicsContext.ResolvedSymbol? = context.resolveSymbol(id: i)
                while let symbol = nextSymbol {
                    symbols.append(symbol)
                    i += 1
                    nextSymbol = context.resolveSymbol(id: i)
                }

                if symbols.isEmpty { return }

                context.translateBy(x: size.width / 2, y: insets.top + (size.height - insets.top - insets.bottom) / 2)

                for item in items {
                    var rng = SeededRandomNumberGenerator(seed: item.id)

                    let symbolIndex = max(0, item.change - 1) % symbols.count

                    let progress = item.progress

                    let angle = Angle.degrees(.random(in: -10 ... 10, using: &rng))

                    let scale = 1 + 0.2 * progress

                    context.opacity = 1.0 - pow(1.0 - 2.0 * progress, 4.0)
                    context.drawLayer { context in
                        context.rotate(by: .degrees(-angle.degrees * Double(1 - progress)))
                        context.translateBy(
                            x: progress * sin(progress * 1.4 * .pi) * .random(in: -20 ... 20, using: &rng),
                            y: progress * -50 - .random(in: 0 ... 10, using: &rng)
                        )
                        context.rotate(by: angle)
                        context.scaleBy(x: scale, y: scale)

                        let symbol = symbols[symbolIndex]

                        context.draw(symbol, at: .zero)
                    }
                }
            } symbols: {
                SwiftUI._VariadicView.Tree(_ViewContainer()) {
                    particles
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
            .particleLayerOverlay(alignment: .top, layer: layer, isEnabled: !isSimulationPaused) {
                overlay
            }
            .onChange(of: impulseCount) { newValue in
                let item = Item(
                    id: UUID(),
                    progress: 0,
                    velocity: initialVelocity,
                    change: newValue
                )
                withAnimation(nil) {
                    items.append(item)
                }
            }
    }

    private func update(_ step: Double) {
        for index in items.indices.reversed() {
            var item = items[index]

            if spring.response > 0 {
                let (newValue, newVelocity) = spring.value(
                    from: item.progress,
                    to: target,
                    velocity: item.velocity,
                    timestep: step
                )
                item.progress = newValue
                item.velocity = newVelocity
            } else {
                item.progress = target
                item.velocity = .zero
            }

            items[index] = item

            if abs(item.progress - target) < 0.04 && item.velocity < 0.04 {
                items.remove(at: index)
            }
        }
    }
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

#if os(iOS) && DEBUG
struct RisingParticleEffect_Previews: PreviewProvider {
    struct ButtonPreview: View {
        @State
        var claps = 28

        @State
        var stars = 18

        @State
        var likes = 61

        var body: some View {
            HStack {
                Button {
                    claps += 1
                } label: {
                    HStack {
                        Image(systemName: "hands.clap.fill")
                        Text(claps.formatted())
                    }
                }
                .changeEffect(.rise(origin: UnitPoint(x: 0.7, y: 0.5)) {
                    Group {
                        Text("+1")
                        Image(systemName: "hands.clap")
                        Image(systemName: "sparkle")
                        Image(systemName: "hand.thumbsup")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
                .tint(.blue)
                }, value: claps)

                Button {
                    stars += 1
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("\(stars, format: .number)")
                    }
                }
                .changeEffect(.rise(origin: UnitPoint(x: 0.7, y: 0.5)) {
                    Text("\(1, format: .number.sign(strategy: .always()))")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.tint)
                }, value: stars)
                .tint(.yellow)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, .init(identifier: "ar_EG"))

                Button {
                    likes += 1
                } label: {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text(likes.formatted())
                    }
                }
                .changeEffect(.rise(origin: UnitPoint(x: 0.3, y: 0.5)) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.tint)
                }, value: likes)
                .clipped()
                .tint(.red)
            }
            .particleLayer(name: "root")
            .buttonStyle(.bordered)
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
                    ForEach(0 ..< 30) { i in
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
                            .changeEffect(.rise(layer: .named("root")) {
                                Image(systemName: "heart.fill").foregroundStyle(.tint)
                            }, value: claps[i, default: 0])
                            .tint(.red)
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
        NavigationView {
            ButtonPreview()
        }
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Buttons")


        ListPreview()
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Escaping List")
    }
}
#endif
