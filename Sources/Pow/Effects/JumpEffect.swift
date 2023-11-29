import SwiftUI

public extension AnyChangeEffect {
    /// An effect that makes the view jump.
    ///
    /// - Parameter height: The height of the jump.
    static func jump(height: CGFloat) -> AnyChangeEffect {
        .simulation { change in
            JumpSimulationModifier(height: height, impulseCount: change)
        }
    }
}

internal struct JumpSimulationModifier: ViewModifier, Simulative {
    var impulseCount: Int

    var initialVelocity: CGFloat = 0

    private let spring = Spring(zeta: 1 / 3, stiffness: 100 * 1)

    @State
    private var displacement: CGFloat = .zero

    @State
    private var velocity: CGFloat = 0.0

    @State
    private var jumpBuffered: Bool = false

    #if os(iOS)
    @State
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    #endif

    private var isSimulationPaused: Bool {
        velocity.isZero
    }

    private var targetHeight: Double

    init(height: Double, impulseCount: Int) {
        self.impulseCount = impulseCount

        precondition(spring.zeta < 1, "Spring must be underdamped")

        let peakTime   = spring.peakTime(initialPosition: 0, initialVelocity: 1)
        let peakHeight = spring.value(initialPosition: 0, initialVelocity: 1, at: peakTime)

        self.initialVelocity = -(height / peakHeight)
        self.targetHeight = height
    }

    public func body(content: Content) -> some View {
        TimelineView(.animation(paused: isSimulationPaused)) { context in
            content
                .modifier(SquishOffset(displacement: displacement))
                .onChange(of: context.date) { (newValue: Date) in
                    let duration = Double(newValue.timeIntervalSince(context.date))
                    withAnimation(nil) {
                        update(max(0, min(duration, 1 / 30)))
                    }
                }
        }
        #if os(iOS)
        .onChange(of: isSimulationPaused) { isPaused in
            if isPaused {
                feedbackGenerator = nil
            } else {
                feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
                feedbackGenerator?.prepare()
            }
        }
        #endif
        .onChange(of: impulseCount) { newValue in
            withAnimation(nil) {
                if displacement > -10 {
                    velocity = -initialVelocity
                    velocity = clamp(-2 * initialVelocity, velocity, 2 * initialVelocity)
                } else if velocity < 0 {
                    jumpBuffered = true
                }
            }
        }
    }

    private func update(_ step: Double) {
        let newValue: Double
        var newVelocity: Double

        if spring.response > 0 {
            // Slow down time as the view approaches its target height for
            // additional hangtime.
            //
            // TODO: Does this mean a `Spring` is just a bad way to model this?
            let speed: Double

            if targetHeight > 32 {
                speed = (1 - 0.8 * clamp(0, -displacement / targetHeight, 1.0))
            } else {
                speed = 1
            }

            (newValue, newVelocity) = spring.value(
                from: displacement,
                to: 0,
                velocity: velocity,
                // Slow down time for a more floaty feeling.
                timestep: step * speed
            )
        } else {
            newValue = 0
            newVelocity = .zero
        }

        if displacement < 0 && newValue >= 0 {
            #if os(iOS)
            feedbackGenerator?.impactOccurred(intensity: clamp(0, newVelocity / 800, 1))
            #endif

            if jumpBuffered {
                newVelocity -= initialVelocity
                jumpBuffered = false
            }
        }

        displacement = newValue
        velocity = newVelocity

        if abs(newValue) < 0.04, newVelocity < 0.04 {
            displacement = 0
            velocity = .zero
        }
    }
}

/// A view modifier that offsets the view vertically for negative values and
/// compresses the view for positive values.
///
/// TODO: Consider merging this with `Boing`.
private struct SquishOffset: GeometryEffect {
    // In points along the y axis.
    var displacement: CGFloat = 0

    internal init(displacement: CGFloat = 0) {
        self.displacement = displacement
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let area = size.width * size.height

        var t = CGAffineTransform.identity

        if displacement < 0 {
            t = t.translatedBy(x: size.width / 2, y: size.height / 2)
            t = t.translatedBy(x: 0, y: displacement)
            t = t.translatedBy(x: -size.width / 2, y: -size.height / 2)
        }

        if displacement > 0 {
            let newHeight = rubberClamp(size.height * 0.8, size.height - displacement / 3, size.height * 1)
            let newWidth  = area / newHeight

            t = t.translatedBy(x: size.width / 2, y: size.height)
            t = t.scaledBy(x: newWidth / size.width, y: newHeight / size.height)
            t = t.translatedBy(x: -size.width / 2, y: -size.height)
        }

        return ProjectionTransform(t)
    }
}

#if os(iOS) && DEBUG
struct JumpSimulation_Previews: PreviewProvider {
    @available(iOS 16.0, *)
    struct Preview: View {
        @State
        var emailCount = 0

        @State
        var height: Double = 100

        var body: some View {
            ZStack {
                Color.clear
                    .background {
                        AsyncImage(url: URL(string: "https://picsum.photos/1200")!, transaction: Transaction(animation: .default)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .ignoresSafeArea()
                            case .failure(let error):
                                Text(error.localizedDescription)
                                    .font(.caption)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }

                VStack {
                    VStack {
                        Stepper("^[\(emailCount) Email](inflect: true)", value: $emailCount, in: 0...999)

                        Slider(value: $height, in: 10 ... 500)
                    }
                    .monospacedDigit()
                    .padding(12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(radius: 8, y: 4)

                    Spacer()

                    HStack(spacing: 29) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.green.gradient)
                            .saturation(1.5)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(.white)
                            }

                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                            .saturation(1.5)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.white)
                            }
                            .overlay(alignment: .topTrailing) {
                                Text(emailCount.formatted())
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .monospacedDigit()
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(.red, in: Capsule(style: .continuous))
                                    .alignmentGuide(.top) { dimensions in
                                        dimensions[VerticalAlignment.center] - 5
                                    }
                                    .alignmentGuide(.trailing) { dimensions in
                                        dimensions[HorizontalAlignment.center] + 5
                                    }
                                    .scaleEffect(
                                        x: emailCount > 0 ? 1 : 0,
                                        y: emailCount > 0 ? 1 : 0
                                    )
                                    .animation(.spring(response: 0.2), value: emailCount > 0)
                            }
                            .changeEffect(.jump(height: height), value: emailCount)
                            .overlay(alignment: .top) {
                                Color.red.frame(height: 3).offset(y: -height)
                            }

                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.orange.gradient)
                            .saturation(1.5)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 34))
                                    .foregroundStyle(.white)
                            }

                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.red.gradient)
                            .saturation(1.5)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: "music.quarternote.3")
                                    .font(.system(size: 34))
                                    .foregroundStyle(.white)
                            }
                    }
                    .fontWeight(.thin)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                }
                .padding()
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    static var previews: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                Preview()
            }
        }
    }
}

struct RepeatingJump: PreviewProvider {
    @available(iOS 16.0, *)
    struct Preview: View {
        @State
        private var isEnabled: Bool = false

        @State
        private var cadence: TimeInterval = 5

        var body: some View {
            VStack {
                GroupBox("Jump") {
                    VStack {
                        Toggle("Enabled", isOn: $isEnabled)

                        LabeledContent {
                            Slider(value: $cadence, in: -1 ... 6)
                        } label: {
                            Text("Cadence")
                        }
                    }
                }

                Spacer()

                let button = Button {

                } label: {
                    Label("Upwards!", systemImage: "arrow.up")
                }
                .tint(.green)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                HStack {
                    button
                        .conditionalEffect(.repeat(.jump(height: 100), every: cadence), condition: isEnabled)

                    button
                        .conditionalEffect(.repeat(.jump(height: 100).delay(2), every: cadence), condition: isEnabled)
                }

                Spacer()
            }
            .padding()
        }
    }

    static var previews: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                Preview()
            }
        }
    }
}

private extension AnyChangeEffect {
    static var overlay: AnyChangeEffect {
        .simulation { count in
            CountOverlayModifier(impulseCount: count)
        }
    }

    struct CountOverlayModifier: ViewModifier, Simulative {
        var impulseCount: Int = 0

        var initialVelocity: CGFloat = 0

        func body(content: Content) -> some View {
            content.overlay {
                Text(impulseCount.formatted())
                    .padding(4)
                    .background(.blue)
            }
        }
    }
}
#endif
