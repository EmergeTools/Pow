import SwiftUI
import simd
#if os(iOS) && EMG_PREVIEWS
import SnapshotPreferences
#endif

#if !os(watchOS)
public extension AnyConditionalEffect {
    /// An effect that emits smoke from the view.
    static var smoke: AnyConditionalEffect {
        .smoke(layer: .local)
    }

    /// An effect that emits smoke from the view.
    ///
    /// - Parameter layer: The `ParticleLayer` on which to render the effect, default is `local`.
    static func smoke(layer: ParticleLayer) -> AnyConditionalEffect {
        .continuous(
            .modifier { isActive in
                SmokeEffect(isActive: isActive, layer: layer)
            }
        )
    }
}
#endif

#if !os(watchOS)
private struct SmokeEffect: ViewModifier, Continuous {
    var isActive: Bool

    let layer: ParticleLayer

    let particles = [
        "anvil_smoke_gray",
        "anvil_smoke_gray_blur",
        "anvil_smoke_gray_alt",
    ]

    func body(content: Content) -> some View {
        content
            .background {
                smoke
                    .mask(alignment: .trailing) {
                        Rectangle()
                    }
                    .allowsHitTesting(false)
            }
            .particleLayerBackground(layer: layer) {
                smoke
                    .overlay {
                        Rectangle()
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                    .allowsHitTesting(false)
            }
    }

    private var smoke: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(particles.enumerated()), id: \.element) { (offset, particle) in
                    #if os(iOS) || os(visionOS) || os(tvOS)
                    let image = UIImage(named: particle, in: .module, with: nil)!.cgImage!
                    #elseif os(macOS)
                    let image = Bundle.module.image(forResource: particle)!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
                    #endif

                    SmokeLayerView(size: proxy.size, isActive: isActive, particle: image, seed: UInt32(offset))
                }
            }
        }
    }
}
#endif

#if os(iOS) || os(visionOS) || os(tvOS)
private class EmitterView: UIView {
    override class var layerClass : AnyClass {
       return CAEmitterLayer.self
    }

    var emitterLayer: CAEmitterLayer {
        layer as! CAEmitterLayer
    }
}
#endif

#if os(macOS)
private class EmitterView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        layer?.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeBackingLayer() -> CALayer {
        CAEmitterLayer()
    }

    var emitterLayer: CAEmitterLayer {
        layer as! CAEmitterLayer
    }

    override var isFlipped: Bool {
        return true
    }
}
#endif

#if !os(watchOS)
private struct SmokeLayerView: ViewRepresentable {
    var size: CGSize

    var isActive: Bool

    var particle: CGImage

    var seed: UInt32

    func makeView(context: Context) -> EmitterView {
        let view = EmitterView()

        let emitterLayer = view.emitterLayer
        emitterLayer.seed = seed

        let particleScale = size.width / 750.0
        let particleWidth: CGFloat = 256
        let inset: CGFloat = particleWidth * particleScale / 2.25

        do {
            emitterLayer.emitterPosition = CGRect(origin: .zero, size: size)
                .divided(atDistance: 100, from: .minYEdge)
                .slice
                .center
            emitterLayer.emitterSize = CGRect(origin: .zero, size: size)
                .divided(atDistance: 100, from: .minYEdge)
                .slice
                .insetBy(dx: inset, dy: inset)
                .size
            emitterLayer.emitterShape = .rectangle

            let cell = CAEmitterCell()
            cell.birthRate = max(10.0, Float(size.width / 5.0))
            cell.lifetime = 1.5
            cell.velocity = min(175, size.width * 0.75)
            cell.velocityRange = 10

            cell.spinRange = .pi

            cell.alphaRange = 1.0
            cell.alphaSpeed = -1.0

            cell.scale = size.width / 750.0
            cell.scaleRange = size.width / 1000.0
            cell.scaleSpeed = size.width / -2000.0

            cell.emissionRange = .pi * 0.1
            cell.emissionLongitude = .pi * -0.5

            cell.contents = particle

            emitterLayer.emitterCells = [cell]

            emitterLayer.lifetime = isActive ? 1 : 0
        }

        return view
    }

    func updateView(_ view: EmitterView, context: Context) {
        view.emitterLayer.lifetime = isActive ? 1 : 0
    }
}
#endif

#if DEBUG && !os(tvOS) && !os(watchOS)
struct ContinuousParticleEffect_Previews: PreviewProvider {
    private struct Preview: View {
        @State
        private var isEnabled: Bool = true

        var body: some View {
            GroupBox("Smoke") {
                VStack {
                    Toggle("Enabled", isOn: $isEnabled)

                    Button {

                    } label: {
                        Label("Burn", systemImage: "opticaldisc.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
//                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .conditionalEffect(.smoke, condition: isEnabled)
                    .tint(.init(white: 0.3))
                }
            }
            .padding()
        }
    }

    private struct PreviewS: View {
        @State
        private var isEnabled: Bool = true

        var body: some View {
            GroupBox("Smoke") {
                VStack {
                    Toggle("Enabled", isOn: $isEnabled)

                    Button {

                    } label: {
                        Label("Burn", systemImage: "opticaldisc.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .conditionalEffect(.smoke, condition: isEnabled)
                    .tint(.init(white: 0.3))
                }
            }
            .padding()
        }
    }

    private struct Preview2: View {
        @State
        private var isEnabled: Bool = true

        var body: some View {
            GroupBox("Smoke") {
                VStack {
                    Toggle("Enabled", isOn: $isEnabled)

                    Button {

                    } label: {
                        Label("Burn", systemImage: "opticaldisc.fill")
                            .foregroundColor(.orange)
                            .font(.largeTitle)
                            .padding(.horizontal, 80)
                            .padding(.vertical, 200)
                    }
                    .buttonStyle(.borderedProminent)
//                    .buttonBorderShape(.roundedRectangle(radius: 70))
                    .controlSize(.large)
                    .conditionalEffect(.smoke, condition: isEnabled)
                    .tint(.init(white: 0.3))
                }
            }
            .padding()
        }
    }

    private struct Preview3: View {
        @State
        private var isEnabled: Bool = true

        var body: some View {
            NavigationView {
                ScrollView {
                    GroupBox("Smoke") {
                        VStack {
                            Button {

                            } label: {
                                Label("Burn", systemImage: "opticaldisc.fill")
                                    .foregroundColor(.orange)
                                    .font(.largeTitle)
                                    .padding()
                                    .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .conditionalEffect(.smoke(layer: .named("root")), condition: isEnabled)
                            .tint(.init(white: 0.3))

                            Toggle("Enabled", isOn: $isEnabled)
                        }
                    }
                    .clipped()
                    .padding()
                }
                .navigationTitle("Smoke")
            }
            .particleLayer(name: "root")
        }
    }

    #if os(iOS)
    private struct PreviewLayer: View {
        @State
        private var isEnabled: Bool = true

        var body: some View {
            VStack {
                GeometryReader { proxy in
                    SmokeLayerView(size: proxy.size, isActive: isEnabled, particle: UIImage(named: "anvil_smoke_gray", in: .module, with: nil)!.cgImage!, seed: 0)
                }
                .frame(width: 200, height: 100)
                .border(.red)

                Toggle("Enabled", isOn: $isEnabled)
            }
            .padding()
        }
    }
    #endif

    private struct PreviewAlt: View {
        @State
        private var isEnabled: Bool = true

        var body: some View {
            GroupBox("Smoke") {
                VStack {
                    Toggle("Enabled", isOn: $isEnabled)

                    Button {

                    } label: {
                        Label("Burn", systemImage: "opticaldisc.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
//                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .conditionalEffect(.smoke, condition: isEnabled)
                    .tint(.init(white: 0.3))
                }
            }
            .padding()
        }
    }

    static var previews: some View {
      Group {
        Preview()
          .preferredColorScheme(.dark)
          .previewDisplayName("Dark")
        Preview()
          .preferredColorScheme(.light)
          .previewDisplayName("Light")
        PreviewS()
          .preferredColorScheme(.dark)
          .previewDisplayName("Small")
        Preview2()
          .preferredColorScheme(.dark)
          .previewDisplayName("Large")
        Preview3()
          .preferredColorScheme(.dark)
          .previewDisplayName("Particle Layer")

#if os(iOS)
        PreviewLayer()
          .previewDisplayName("Emitter Layer")
#endif

        PreviewAlt()
          .preferredColorScheme(.dark)
          .previewDisplayName("Emitter Dark")
      }
      #if os(iOS) && EMG_PREVIEWS
        .emergeSnapshotPrecision(0)
      #endif
    }
}
#endif
