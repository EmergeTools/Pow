import SwiftUI

public extension AnyChangeEffect {
    /// Specifies how a `pulse` change effect should render its shape style.
    enum PulseDrawingMode {
        /// Renders the shape style by filling the shape.
        case fill

        /// Renders the shape style as a stroke to the shape's path.
        case stroke
    }

    /// An effect that adds one or more shapes that slowly grow and fade-out behind the view.
    ///
    /// - Parameters:
    ///   - shape: The shape to use for the effect.
    ///   - style: The shape style to use for the effect. Defaults to `tint`.
    ///   - drawingMode: The mode used to render the shape. Defaults to `fill`.
    ///   - count: The number of shapes to emit. Defaults to `1`.
    ///   - layer: The `ParticleLayer` on which to render the effect. Defaults to `local`.
    static func pulse(shape: some InsettableShape, style: some ShapeStyle = .tint, drawingMode: PulseDrawingMode = .fill, count: Int = 1, layer: ParticleLayer = .local) -> AnyChangeEffect {
        let clampedCount = max(1, count)
        let cooldown: Double = Double(clampedCount - 1) * 0.2
        switch drawingMode {
        case .stroke:
            return .animation({ change in
                PulseStrokeModifier(shape: shape, style: style, layer: layer, count: clampedCount, change: change)
            }, animation: .linear(duration: 2), cooldown: cooldown)
        case .fill:
            return .animation({ change in
                PulseFillModifier(shape: shape, style: style, layer: layer, count: clampedCount, change: change)
            }, animation: .linear(duration: 4), cooldown: cooldown)
        }
    }
}

private final class ItemTimer: ObservableObject {
    @Published
    private(set) var items: [UUID] = []

    @Published
    private(set) var pulsesRemaining: Int = 0 {
        didSet {
            if oldValue == 0, pulsesRemaining > 0 {
                resume()
            }
        }
    }

    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }

    init() {}

    func remove(_ item: UUID) {
        items.removeAll { $0 == item }
    }

    func queue(pulses: Int) {
        pulsesRemaining += pulses
    }

    private func resume(interval: TimeInterval = 0.2, delay: TimeInterval = 0) {
        if delay != 0 {
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] t in
                self?.resume(interval: interval)
            }
        } else {
            if pulsesRemaining > 0 {
                items.append(UUID())
                pulsesRemaining -= 1
                reschedule(interval: interval)
            }
        }
    }

    private func reschedule(interval: TimeInterval = 0.2) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] t in
            self?.resume(interval: interval)
        }
    }

    func pause() {
        timer = nil
    }
}

private struct PulseStrokeModifier<EffectShape: InsettableShape, EffectShapeStyle: ShapeStyle>: ViewModifier, Animatable, AnimatableModifier {
    var shape: EffectShape

    var style: EffectShapeStyle

    var layer: ParticleLayer

    var count: Int

    var change: Int

    var animatableData = EmptyAnimatableData()

    @StateObject
    private var timer: ItemTimer = ItemTimer()

    public func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    let insetAmount = min(proxy.size.width, proxy.size.height) * 2.0
                    let lineWidth = max(1, insetAmount / 25)

                    ZStack {
                        ForEach(timer.items, id: \.self) { item in
                            shape
                                .fill(.clear)
                                .transition(
                                    AnyTransition.asymmetric(
                                        insertion: .movingParts.pulseStroke(shape: shape, style: style, lineWidth: lineWidth, layer: layer, insetAmount: insetAmount, count: count) {
                                            timer.remove(item)
                                        },
                                        removal: .identity
                                    )
                                )
                        }
                    }
                    .compositingGroup()
                }
                .allowsHitTesting(false)
            }
            .onChange(of: change) { c in
                timer.queue(pulses: max(0, count))
            }
    }
}

private struct PulseFillModifier<EffectShape: InsettableShape, EffectShapeStyle: ShapeStyle>: ViewModifier, Animatable, AnimatableModifier {
    var shape: EffectShape

    var style: EffectShapeStyle

    var layer: ParticleLayer

    var count: Int

    var change: Int

    var animatableData = EmptyAnimatableData()

    @StateObject
    private var timer: ItemTimer = ItemTimer()

    public func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    let insetAmount: CGFloat = min(proxy.size.width, proxy.size.height) * 2.0

                    ZStack {
                        ForEach(timer.items, id: \.self) { item in
                            shape
                                .fill(.clear)
                                .transition(
                                    AnyTransition.asymmetric(
                                        insertion: .movingParts.pulseFill(shape: shape, style: style, layer: layer, insetAmount: insetAmount, count: count) {
                                            timer.remove(item)
                                        },
                                        removal: .identity
                                    )
                                )
                        }
                    }
                    .compositingGroup()
                }
            }
            .onChange(of: change) { _ in
                timer.queue(pulses: max(0, count))
            }
    }
}

private extension AnyTransition.MovingParts {
    static func pulseStroke(shape: some InsettableShape, style: some ShapeStyle, lineWidth: CGFloat, layer: ParticleLayer, insetAmount: CGFloat, count: Int, onCompletion: @escaping () -> Void) -> AnyTransition {
        .modifier(
            active: PulseStrokeAnimationModifier(
                animatableData: 0.0,
                shape: shape,
                style: style,
                lineWidth: lineWidth,
                layer: layer,
                insetAmount: insetAmount
            ),
            identity: PulseStrokeAnimationModifier(
                animatableData: 1.0,
                shape: shape,
                style: style,
                lineWidth: lineWidth,
                layer: layer,
                insetAmount: insetAmount,
                onCompletion: onCompletion
            )
        )
    }

    static func pulseFill(shape: some InsettableShape, style: some ShapeStyle, layer: ParticleLayer, insetAmount: CGFloat, count: Int, onCompletion: @escaping () -> Void) -> AnyTransition {
        .modifier(
            active: PulseFillAnimationModifier(
                animatableData: 0.0,
                shape: shape,
                style: style,
                layer: layer,
                insetAmount: insetAmount
            ),
            identity: PulseFillAnimationModifier(
                animatableData: 1.0,
                shape: shape,
                style: style,
                layer: layer,
                insetAmount: insetAmount,
                onCompletion: onCompletion
            )
        )
    }
}

private struct PulseStrokeAnimationModifier<EffectShape: InsettableShape, EffectShapeStyle: ShapeStyle>: ViewModifier, Animatable, AnimatableModifier {
    var animatableData: CGFloat

    var shape: EffectShape

    var style: EffectShapeStyle

    var lineWidth: CGFloat

    var layer: ParticleLayer

    var insetAmount: CGFloat

    var onCompletion: () -> Void = {}

    @Environment(\.colorScheme)
    private var colorScheme

    func body(content: Content) -> some View {
        content
            .particleLayerOverlay(layer: layer) {
                let progress = animatableData
                let x: CGFloat = progress.beat(intensity: 5.0, frequency: 0.5)
                let nx: CGFloat = x - 0.5
                let v: CGFloat = sin(.pi * x)

                shape
                    .inset(by: nx * -insetAmount)
                    .strokeBorder(style, lineWidth: lineWidth * v)
                    .opacity(1.0 - asin(.pi * Double(progress) / 2.0))
                    .blur(radius: lineWidth * 0.125 * v)
                    .brightness(colorScheme == .dark ? Double(v) * 0.75 : 0.0)
            }
            .animation(nil, value: animatableData)
            .onChange(of: animatableData == 1.0) { newValue in
                if newValue {
                    onCompletion()
                }
            }
    }
}

private struct PulseFillAnimationModifier<EffectShape: InsettableShape, EffectShapeStyle: ShapeStyle>: ViewModifier, Animatable, AnimatableModifier {
    var animatableData: CGFloat

    var shape: EffectShape

    var style: EffectShapeStyle

    var layer: ParticleLayer

    var insetAmount: CGFloat

    var onCompletion: () -> Void = {}

    @Environment(\.colorScheme)
    private var colorScheme

    func body(content: Content) -> some View {

        content
            .particleLayerBackground(layer: layer) {
                let progress = animatableData
                let x: CGFloat = progress.beat(intensity: 5.0, frequency: 0.5)
                let nx: CGFloat = x - 0.5

                shape
                    .inset(by: nx * -insetAmount)
                    .fill(style)
                    .opacity(0.33 - asin(.pi * Double(progress) / 2.0))
            }
            .animation(nil, value: animatableData)
            .onChange(of: animatableData == 1.0) { newValue in
                if newValue {
                    onCompletion()
                }
            }
    }
}


private extension CGFloat {
    func beat(intensity: CGFloat = 2.0, frequency: CGFloat = 2.0) -> CGFloat {
        let v = atan(sin(self * .pi * frequency) * intensity)
        return (v + .pi / 2.0) / .pi
    }
}

#if os(iOS) && DEBUG
struct PulseEffect_Previews: PreviewProvider {
    struct Preview: View {
        @State
        private var pingCount = 0

        @State
        private var pulseCount = 0

        @State
        private var isPressingPulse = false

        @State
        private var hearbeatCount = 0

        @State
        private var isPressingHeartbeat = false

        var body: some View {
            VStack(spacing: 8) {
                Spacer()

                Label("Ping (New)", systemImage: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.white)
                    .padding()
                    .background(.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .changeEffect(.pulse(shape: RoundedRectangle(cornerRadius: 16, style: .continuous), count: 3), value: pingCount)
                    .tint(.green)
                    .onTapGesture {
                        pingCount += 1
                    }

                Spacer()

                VStack(spacing: 32) {
                    let scale = isPressingPulse ? 0.95 : 1.0
                    Label("Pulse", systemImage: "waveform.path.ecg")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.mint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .brightness(isPressingPulse ? -0.15 : 0)
                        .scaleEffect(x: scale, y: scale)
                        .animation(.spring(response: isPressingPulse ? 0.1 : 0.4, dampingFraction: isPressingPulse ? 1 : 0.5), value: isPressingPulse)
                        .changeEffect(.shine(duration: 0.5), value: pulseCount)
                        .changeEffect(.pulse(shape: RoundedRectangle(cornerRadius: 16, style: .continuous), drawingMode: .stroke, count: 3, layer: .named("root")).delay(0.1), value: pulseCount)
                        .tint(.mint)
                        .font(.system(.title, design: .rounded).bold())
                }
                ._onButtonGesture(pressing: { pressing in
                    isPressingPulse = pressing
                }, perform: {
                    pulseCount += 1
                })
                .padding()
                .clipped()

                Spacer()

                Group {
                    VStack(spacing: 32) {
                        let scale = isPressingHeartbeat ? 0.95 : 1.0
                        Label("Update", systemImage: "heart.circle")
                            .foregroundStyle(.red, .red.opacity(0.5))
                            .brightness(isPressingHeartbeat ? -0.15 : 0)
                            .scaleEffect(x: scale, y: scale)
                            .animation(.spring(response: isPressingHeartbeat ? 0.1 : 0.4, dampingFraction: isPressingHeartbeat ? 1 : 0.5), value: isPressingHeartbeat)
                            .changeEffect(.shine(duration: 0.5), value: hearbeatCount)
                            .changeEffect(.pulse(shape: Circle().inset(by: 6.5), style: .red, drawingMode: .stroke, count: 50).delay(0.1), value: hearbeatCount)
                            .font(.system(size: 72, design: .rounded))
                    }
                    ._onButtonGesture(pressing: { pressing in
                        isPressingHeartbeat = pressing
                    }, perform: {
                        hearbeatCount += 1
                    })
                    .labelStyle(.iconOnly)

                    VStack(spacing: 32) {
                        let scale = isPressingHeartbeat ? 0.95 : 1.0
                        Label("Update", systemImage: "heart.circle")
                            .foregroundStyle(.red, .red.opacity(0.5))
                            .brightness(isPressingHeartbeat ? -0.15 : 0)
                            .scaleEffect(x: scale, y: scale)
                            .animation(.spring(response: isPressingHeartbeat ? 0.1 : 0.4, dampingFraction: isPressingHeartbeat ? 1 : 0.5), value: isPressingHeartbeat)
                            .changeEffect(.shine(duration: 0.5), value: hearbeatCount)
                            .changeEffect(.pulse(shape: Circle().inset(by: 6.5), style: .red, drawingMode: .stroke).delay(0.1), value: hearbeatCount)
                    }
                    ._onButtonGesture(pressing: { pressing in
                        isPressingHeartbeat = pressing
                    }, perform: {
                        hearbeatCount += 1
                    })
                    .labelStyle(.iconOnly)
                }

                Spacer()

                VStack {
                    Stepper(value: $pingCount) {
                        Text("Pings ") + Text("(\(pingCount.formatted()))").foregroundColor(.secondary)
                    }
                    Stepper(value: $pulseCount) {
                        Text("Pulses ") + Text("(\(pulseCount.formatted()))").foregroundColor(.secondary)
                    }
                    Stepper(value: $hearbeatCount) {
                        Text("Heartbeats ") + Text("(\(hearbeatCount.formatted()))").foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .particleLayer(name: "root")
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Color Scheme")
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light Color Scheme")
    }
}
#endif
