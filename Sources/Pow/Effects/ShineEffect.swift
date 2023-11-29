import SwiftUI

public extension AnyChangeEffect {
    /// An effect that highlights the view with a shine moving over the view.
    ///
    /// The shine moves from the top leading edge to bottom trailing edge.
    static var shine: AnyChangeEffect {
        shine(duration: 1)
    }

    /// An effect that highlights the view with a shine moving over the view.
    ///
    /// The shine moves from the top leading edge to bottom trailing edge.
    static func shine(duration: Double) -> AnyChangeEffect {
        .animation({ change in
            ShineModifier(angle: nil, animatableData: CGFloat(change))
        }, animation: .easeInOut(duration: duration), cooldown: duration * 0.5)
    }

    /// An effect that highlights the view with a shine moving over the view.
    ///
    /// The angle is relative to the current `layoutDirection`, such that 0° represents sweeping towards the trailing edge and 90° represents sweeping towards the bottom edge.
    ///
    /// - Parameters:
    ///   - angle: The angle of the animation.
    ///   - duration: The duration of the animation.
    static func shine(angle: Angle, duration: Double = 1.0) -> AnyChangeEffect {
        .animation({ change in
            ShineModifier(angle: angle, animatableData: CGFloat(change))
        }, animation: .easeInOut(duration: duration), cooldown: duration * 0.5)
    }
}

internal struct ShineModifier: ViewModifier, Animatable {
    var angle: Angle?

    public var animatableData: CGFloat = 0
    public func body(content: Content) -> some View {
        let fraction = CGFloat(fmodf(Float(animatableData), 1))

        content
            .overlay(
                GeometryReader { proxy in
                    let base = sin(Double(fraction))

                    let frame = CGRect(origin: .zero, size: proxy.size)

                    let resolvedAngle = angle ?? frame.topLeft.angle(to: frame.bottomRight)

                    let bounds = frame.boundingBox(at: resolvedAngle)

                    LinearGradient(
                        colors: stride(from: 0.0, through: .pi, by: 0.2).map {
                            .white.opacity(pow(sin($0), 2) * 0.8 * base)
                        },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: bounds.width * 2, height: bounds.height)
                    .position(
                        x: (bounds.minX - bounds.width / 2) + (fraction * bounds.width * 2),
                        y: bounds.midY
                    )
                    .rotationEffect(resolvedAngle)
                    .blendMode(.sourceAtop)
                    .opacity(1.0 - pow(fraction, 8.0))
                }
                .allowsHitTesting(false)
            )
            .compositingGroup()
            .animation(nil, value: fraction)
    }
}

#if os(iOS) && DEBUG
struct ShineChangeEffect_Previews: PreviewProvider {
    struct Cart: View {
        @State
        var itemCount: Int = 0

        @State private var degrees: Double = 45

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
                            Stepper(value: $itemCount, in: 0...10) {
                                Text("Quantity ") + Text(itemCount.formatted()).foregroundColor(.secondary)
                            }
                            .labelsHidden()
                            .font(.callout)
                        }
                        .font(.callout)
                    }
                }

                Text(degrees, format: .number.precision(.fractionLength(2)))
                Slider(value: $degrees, in: -360.0...360.0)

            }
            .listStyle(.plain)
            .navigationTitle("Cart")
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 32) {
                    Button {
                    } label: {
                        Label("Checkout", systemImage: "cart")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(itemCount == 0)
                    .animation(.default, value: itemCount == 0)
                    .changeEffect(
                        .shine(angle: .degrees(degrees)).delay(0.5),
                        value: itemCount,
                        isEnabled: itemCount > 0
                    )
                    .padding()
                }
            }
        }
    }

    static var previews: some View {
        NavigationView {
            Cart()
        }
    }
}
#endif
