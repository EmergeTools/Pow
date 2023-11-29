import SwiftUI

public extension AnyChangeEffect {
    /// An effect that highlights the view with a glow around it.
    ///
    /// The glow appears for a second.
    static var glow: AnyChangeEffect {
        glow(color: .accentColor)
    }

    /// An effect that highlights the view with a glow around it.
    ///
    /// The glow appears for a second.
    ///
    /// - Parameters:
    ///   - color: The color of the glow.
    ///   - radius: The radius of the glow.
    static func glow(color: Color, radius: CGFloat = 16) -> AnyChangeEffect {
        .simulation { change in
            PulseGlowModifier(impulseCount: change, color: color, radius: min(100, radius))
        }
    }
}

public extension AnyConditionalEffect {
    /// An effect that highlights the view with a glow around it.
    static var glow: AnyConditionalEffect {
        glow(color: .accentColor)
    }

    /// An effect that highlights the view with a glow around it.
    ///
    /// - Parameters:
    ///   - color: The color of the glow.
    ///   - radius: The radius of the glow.
    static func glow(color: Color, radius: CGFloat = 16) -> AnyConditionalEffect {
        .continuous(
            .modifier { isActive in
                ContinuousGlowModifier(color: color, radius: radius, isActive: isActive)
            }
        )
    }
}

internal struct GlowModifier: ViewModifier, Animatable {
    var animatableData: CGFloat

    var color: Color

    var radius: CGFloat

    let ramp = cubicBezier(x1: 0.3, y1: 0.0, x2: 0.7, y2: 1)

    init(glow: CGFloat, color: Color, radius: CGFloat) {
        self.animatableData = glow
        self.color = color
        self.radius = radius
    }

    var glow: CGFloat {
        get { animatableData }
        set { animatableData = newValue }
    }

    func body(content: Content) -> some View {
        let amount = min(glow, 1.5)

        let shadowOpacity = sqrt(amount)

        content
            .transformEnvironment(\.backgroundMaterial) { material in
                material = nil
            }
            .overlay {
                color
                    .opacity(ramp(amount))
                    .blendMode(.sourceAtop)
                    .brightness(ramp(abs(amount)) * 0.1)
            }
            .compositingGroup()
            .shadow(color: color.opacity(shadowOpacity /  1.2), radius: amount * radius / 4.0, x: 0, y: 0)
            .shadow(color: color.opacity(shadowOpacity /  4.0), radius: amount * radius / 2.0, x: 0, y: 0)
            .shadow(color: color.opacity(shadowOpacity /  8.0), radius: amount * radius,       x: 0, y: 0)
            .shadow(color: color.opacity(shadowOpacity / 16.0), radius: amount * radius * 2.0, x: 0, y: 0)
            .brightness(ramp(abs(amount)) * 0.25)
            .animation(nil, value: amount)
    }
}

internal struct ContinuousGlowModifier: ViewModifier, Continuous {
    var color: Color

    var radius: CGFloat

    var isActive: Bool

    init(color: Color, radius: CGFloat, isActive: Bool) {
        self.color = color
        self.radius = radius
        self.isActive = isActive
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                GlowModifier(glow: isActive ? 0.7 : 0, color: color, radius: radius)
                    .animation(.easeInOut(duration: 0.25))
            )
    }
}

internal struct PulseGlowModifier: ViewModifier, Simulative {
    var impulseCount: Int

    var initialVelocity: CGFloat = 0

    let spring = Spring(zeta: 0.75, stiffness: 15, mass: 1)

    var color: Color

    var radius: CGFloat

    @State
    private var targetGlow: CGFloat = 0.0

    @State
    private var glow: CGFloat = 0.0

    @State
    private var glowVelocity: CGFloat = 0.0

    private var isSimulationPaused: Bool {
        targetGlow == glow && abs(glowVelocity) <= 0.02
    }

    internal func body(content: Content) -> some View {
        TimelineView(.animation(paused: isSimulationPaused)) { context in
            content
                .modifier(GlowModifier(glow: glow, color: color, radius: radius))
                .onChange(of: context.date) { (newValue: Date) in
                    let duration = Double(newValue.timeIntervalSince(context.date))
                    withAnimation(nil) {
                        update(clamp(0, duration, 1 / 30))
                    }
                }
        }
        .onChange(of: impulseCount) { newValue in
            withAnimation(nil) {
                if glowVelocity <= 0.05 {
                    glowVelocity = 5
                } else {
                    glowVelocity += 1.5
                }

                glowVelocity = min(glowVelocity, 5)
            }
        }
    }

    private func update(_ step: Double) {
        let newValue: Double
        let newVelocity: Double

        if spring.response > 0 {
            (newValue, newVelocity) = spring.value(
                from: glow,
                to: targetGlow,
                velocity: glowVelocity,
                timestep: step
            )
        } else {
            newValue = targetGlow
            newVelocity = 0.0
        }

        glow = newValue
        glowVelocity = newVelocity

        if abs(newValue - targetGlow) < 0.01, newVelocity < 0.01 {
            glow = targetGlow
            glowVelocity = 0.0
        }
    }
}

#if os(iOS) && DEBUG
struct GlowChangeEffect_Previews: PreviewProvider {
    struct Cart: View {
        @State
        var itemCount: Int = 1

        var total: Double {
            9.99 * Double(itemCount)
        }

        var body: some View {
            List {
                HStack(alignment: .center, spacing: 16) {
                    AsyncImage(url: URL(string: "https://movingparts.io/frontpage/checkout-smooth-blend@3x.png")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .background(Color(white: 0.9))
                    .frame(width: 72, height: 72)
                    .changeEffect(.shine(angle: .degrees(180), duration: 0.5), value: itemCount, isEnabled: itemCount > 0)

                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Seasonal Blend, Spring Here")
                                .font(.body.weight(.medium))
                                .lineSpacing(-10)

                            Text("500g")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("\(itemCount.formatted())× ").foregroundColor(.secondary) +
                            Text(9.99.formatted(.currency(code: "EUR")))
                            Stepper(value: $itemCount, in: 0...1000) {
                                Text("Quantity ") + Text(itemCount.formatted()).foregroundColor(.secondary)
                            }
                            .labelsHidden()
                            .font(.callout)
                        }
                        .font(.callout)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Cart")
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack {
                    if #available(iOS 16.0, *) {
                        LabeledContent("Subtotal", value: total, format: .currency(code: "USD"))
                        LabeledContent("Shipping", value: 0, format: .currency(code: "USD"))
                        LabeledContent("Total") {
                            Text(total, format: .currency(code: "USD"))
                                .foregroundStyle(.primary)
                                .changeEffect(.glow(color: .accentColor, radius: 32), value: itemCount)
                        }
                        .tint(.red)
                        .bold()
                    }

                    Divider().hidden()

                    Button {
                    } label: {
                        Label("Checkout", systemImage: "cart")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(itemCount == 0)
                    .animation(.default, value: itemCount == 0)
                }
                .monospacedDigit()
                .padding()
                .background(.regularMaterial)
            }
        }
    }

    struct Preview: View {
        @State
        var isOn = false

        var body: some View {
            VStack {
                Spacer()

                Button("Continue") {

                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .conditionalEffect(.repeat(.glow(color: .blue, radius: 50), every: 1.5), condition: isOn)

                Button("Continue") {

                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .conditionalEffect(.glow(color: .blue, radius: 50), condition: isOn)

                Spacer()

                Toggle("Enabled", isOn: $isOn)
            }
            .padding()
        }
    }

    static var previews: some View {
        NavigationView {
            Cart()
        }
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .xxLarge)
        .previewDisplayName("Change Effect")

        Preview()
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .xxLarge)
            .previewDisplayName("Conditional Effect")
    }
}
#endif
