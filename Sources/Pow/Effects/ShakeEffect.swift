import SwiftUI

#if !os(watchOS)
public extension AnyChangeEffect {
    /// An effect that shakes the view when a change happens.
    static var shake: AnyChangeEffect {
        .simulation { change in
            ShakeSimulationModifier(impulseCount: change, phaseLength: ShakeRate.default.phaseLength)
        }
    }

    /// The rate of the shake effect.
    enum ShakeRate {
        case `default`
        case fast
        case phaseLength(CGFloat)

        fileprivate var phaseLength: CGFloat {
            switch self {
            case .default: return 0.8
            case .fast: return 0.3
            case .phaseLength(let phaseLength): return phaseLength
            }
        }
    }

    /// An effect that shakes the view when a change happens.
    ///
    /// - Parameter rate: The rate of the shake.
    static func shake(rate: ShakeRate) -> AnyChangeEffect {
        .simulation { change in
            ShakeSimulationModifier(impulseCount: change, phaseLength: rate.phaseLength)
        }
    }
}
#endif

#if !os(watchOS)
internal struct ShakeSimulationModifier: ViewModifier, Simulative {
    // TODO: Not used, remove from protocol
    var initialVelocity: CGFloat = 0

    var impulseCount: Int

    var phaseLength: CGFloat

    @State
    private var shakeCount: CGFloat = 0

    @State
    private var displacement: CGFloat = 0

    @State
    private var integrator: SecondOrderDynamics<CGFloat> = SecondOrderDynamics(
        f: 3,
        zeta: 0.85,
        r: -0.2
    )

    fileprivate var target: CGFloat {
        16 * sin(2 * .pi * shakeCount)
    }

    private var isSimulationPaused: Bool {
        displacement == .zero && shakeCount <= 0
    }

    public func body(content: Content) -> some View {
        let t = Transform3DEffect(
            translation: (displacement, 0, -20),
            angle: .degrees(displacement / 2),
            axis: (0, 1, 0),
            anchorZ: -20,
            perspective: 1 / 6
        )

        TimelineView(.animation(paused: isSimulationPaused)) { context in
            content
                .modifier(t)
                .onChange(of: context.date) { (newValue: Date) in
                    let duration = Double(newValue.timeIntervalSince(context.date))
                    withAnimation(nil) {
                        update(max(0, min(duration, 1 / 30)))
                    }
                }
        }
        .onChange(of: impulseCount) { newValue in
            withAnimation(nil) {
                shakeCount += 2

                if shakeCount > 3 {
                    shakeCount = 2 + fmod(shakeCount, 1)
                }
            }
        }
    }

    private func update(_ step: Double) {
        displacement = integrator.update(target: target, timestep: step)

        if !displacement.isNormal {
            displacement = 0
        }

        shakeCount = clamp(0, shakeCount - 2 * (step / phaseLength), .infinity)
    }
}
#endif

#if os(iOS) && DEBUG
struct ShakeSimulation_Previews: PreviewProvider {
    @available(iOS 16.0, *)
    struct Preview: View {
        @State
        var emailCount = 0

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
                    Stepper("^[\(emailCount) Email](inflect: true)", value: $emailCount, in: 0...999)
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
                            .changeEffect(.shake, value: emailCount)

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
#endif
