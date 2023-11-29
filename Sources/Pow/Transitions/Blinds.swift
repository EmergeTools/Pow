import SwiftUI

public extension AnyTransition.MovingParts {
    /// The style of blinds to use with a `blinds` transition.
    enum BlindsStyle: Sendable {
        /// Blinds with slats that cover the width of the view.
        case venetian
        /// Blinds with slats that cover the height of the view.
        case vertical
    }

    /// A transition that reveals the view as if it was behind window blinds.
    static var blinds: AnyTransition {
        blinds(slatWidth: 10)
    }

    /// A transition that reveals the view as if it was behind window blinds.
    ///
    /// - Parameters:
    ///   - slatWidth: The width of each slat.
    ///   - style: The style of blinds.
    ///   - isStaggered: Whether all slats opens at the same time or in sequence.
    static func blinds(slatWidth: CGFloat, style: BlindsStyle = .venetian, isStaggered: Bool = false) -> AnyTransition {
        let clampedHeight = clamp(5, slatWidth, .greatestFiniteMagnitude)

        return .modifier(
            active:   Blinds(slatWidth: clampedHeight, style: style, isStaggered: isStaggered, animatableData: 0),
            identity: Blinds(slatWidth: clampedHeight, style: style, isStaggered: isStaggered, animatableData: 1)
        )
    }
}

internal struct Blinds: ViewModifier, Animatable, AnimatableModifier, Hashable {
    var slatWidth: CGFloat

    var style: AnyTransition.MovingParts.BlindsStyle

    var isStaggered: Bool

    var animatableData: CGFloat

    private var progress: CGFloat {
        get { animatableData }
        set { animatableData = newValue }
    }

    func body(content: Content) -> some View {
        content
            .mask {
                BlindsShape(slatWidth: slatWidth, style: style, open: progress, isStaggered: isStaggered)
                    .flipsForRightToLeftLayoutDirection(true)
            }
    }
}

private struct BlindsShape: Shape {
    var slatWidth: CGFloat

    var style: AnyTransition.MovingParts.BlindsStyle

    var open: Double

    var isStaggered: Bool

    func path(in rect: CGRect) -> Path {
        let slatCount: Int
        switch style {
        case .venetian:
            slatCount = Int((rect.height / slatWidth).rounded(.up))
        case .vertical:
            slatCount = Int((rect.width / slatWidth).rounded(.up))
        }

        let slatRects = (0 ..< slatCount)
            .map { slatIndex -> CGRect in
                let progress: Double
                if isStaggered {
                    let fraction = 1.0 - (Double(slatIndex) / Double(slatCount))
                    progress = clamp(0.0, (open * 2.0 - 1.0) + fraction, 1.0)
                } else {
                    progress = open
                }

                let position = Double(slatIndex) * slatWidth + slatWidth * (1.0 - progress) / 2.0

                switch style {
                case .venetian:
                    return CGRect(
                        x: 0,
                        y: position,
                        width: rect.width,
                        height: slatWidth * progress
                    )
                case .vertical:
                    return CGRect(
                        x: position,
                        y: 0,
                        width: slatWidth * progress,
                        height: rect.height
                    )
                }
            }

        return Path { path in
            path.addRects(slatRects, transform: CGAffineTransform.identity)
        }
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Blinds_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        @State
        var slatWidth: CGFloat = 10

        @State
        var blindsStyle: AnyTransition.MovingParts.BlindsStyle = .venetian

        @State
        var isStaggered: Bool = false

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Blinds")
                            .bold()

                        Text("""
                        myView.transition(
                            .movingParts.blinds(slatWidth: 15, isStaggered: true))
                        )
                        """)
                    }
                    .font(.footnote.monospaced())
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.thickMaterial)
                    )

                    Stepper {
                        Text("View Count ") + Text("(\(indices.count))").foregroundColor(.secondary)
                    } onIncrement: {
                        withAnimation {
                            indices.append(UUID())
                        }
                    } onDecrement: {
                        if !indices.isEmpty {
                            let _ = withAnimation {
                                indices.removeLast()
                            }
                        }
                    }

                    if #available(iOS 16.0, *) {
                        LabeledContent {
                            Slider(value: $slatWidth, in: 0...50)
                        } label: {
                            ZStack {
                                Text("99").hidden()
                                Text(slatWidth, format: .number.precision(.fractionLength(0)))
                            }
                            .monospacedDigit()
                        }
                    }

                    if #available(iOS 16.0, *) {
                        LabeledContent("Style") {
                            Picker("Picker", selection: $blindsStyle) {
                                Text("Venetian").tag(AnyTransition.MovingParts.BlindsStyle.venetian)
                                Text("Vertical").tag(AnyTransition.MovingParts.BlindsStyle.vertical)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Toggle("Staggered", isOn: $isStaggered)


                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible())
                    ]

                    LazyVGrid(columns: columns) {
                        ForEach(indices, id: \.self) { uuid in
                            ZStack {
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(Color.accentColor)

                                Text("Hello\nWorld!")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(.title, design: .rounded))

                            }
                            .transition(.movingParts.blinds(slatWidth: slatWidth, style: blindsStyle, isStaggered: isStaggered))
                            .aspectRatio(2, contentMode: .fit)
                            .id(uuid)
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
    }
}
#endif
