import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition using a sweep from the specified edge on insertion, and
    /// towards it on removal.
    ///
    /// - Parameters:
    ///   - edge: The edge at which the sweep starts or ends.
    ///   - blurRadius: The radius of the blur applied to the mask.
    static func wipe(edge: Edge, blurRadius: CGFloat = 0) -> AnyTransition {
        let angle: Angle

        switch edge {
        case .top:
            angle = .degrees(90)
        case .leading:
            angle = .degrees(0)
        case .bottom:
            angle = .degrees(270)
        case .trailing:
            angle = .degrees(180)
        }

        return .modifier(
            active:   Wipe(angle: angle, blurRadius: blurRadius, progress: 0),
            identity: Wipe(angle: angle, blurRadius: blurRadius, progress: 1)
        )
    }

    /// A transition using a sweep at the specified angle.
    ///
    /// The angle is relative to the current `layoutDirection`, such that 0° represents sweeping towards the trailing edge on insertion and 90° represents sweeping towards the bottom edge.
    ///
    /// In this example, the view insertion is animated by sweeping diagonally
    /// from the top leading corner towards the bottom trailing corner.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .transition(
    ///         .asymmetric(
    ///             insertion: .movingParts.wipe(angle: .degrees( 45), blurRadius: 10),
    ///             removal:   .movingParts.wipe(angle: .degrees(225), blurRadius: 10)
    ///         )
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - angle: The angle of the animation.
    ///   - blurRadius: The radius of the blur applied to the mask.
    static func wipe(angle: Angle, blurRadius: CGFloat = 0) -> AnyTransition {
        .modifier(
            active:   Wipe(angle: angle, blurRadius: blurRadius, progress: 0),
            identity: Wipe(angle: angle, blurRadius: blurRadius, progress: 1)
        )
    }
}

private struct Wipe: ViewModifier, Animatable, AnimatableModifier {
    var angle: Angle

    var animatableData: AnimatablePair<CGFloat, CGFloat>

    internal init(angle: Angle, blurRadius: CGFloat = 0, progress: CGFloat) {
        self.angle = angle
        self.animatableData = AnimatableData(progress, clamp(0, blurRadius, 30))
    }

    var progress: CGFloat {
        animatableData.first
    }

    var blurRadius: CGFloat {
        animatableData.second
    }

    func body(content: Content) -> some View {
        content
            .mask(
                GeometryReader { proxy in
                    mask(size: proxy.size)
                        .blur(radius: blurRadius * (1 - progress))
                        .compositingGroup()
                }
                .padding(-blurRadius)
                .animation(nil, value: animatableData)
            )
    }

    @ViewBuilder
    func mask(size: CGSize) -> some View {
        let bounds = CGRect(origin: .zero, size: size).boundingBox(at: angle)

        ZStack(alignment: .leading) {
            Color.clear

            Rectangle()
                .frame(width: progress * bounds.width)
        }
        .frame(width: bounds.width, height: bounds.height)
        .position(
            x: bounds.midX,
            y: bounds.midY
        )
        .rotationEffect(angle)
        .animation(nil, value: progress)
        .animation(nil, value: angle)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Wipe_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        enum DirectionType: String, Hashable, Identifiable, CaseIterable {
            case edge = "Edge"
            case angle = "Angle"

            var name: String {
                return rawValue
            }

            var id: Self {
                return self
            }
        }

        @State
        var directionType: DirectionType = .edge

        @State
        var edge: Edge = .leading

        @State
        var angle: Angle = .degrees(0)

        @State
        var blurRadius: CGFloat = 0

        @State
        var isRightToLeft: Bool = false

        func makeTransition() -> AnyTransition {
            switch directionType {
            case .edge:
                return .movingParts.wipe(edge: edge, blurRadius: blurRadius)
            case .angle:
                return .movingParts.wipe(angle: angle, blurRadius: blurRadius)
            }
        }

        var resolvedAngle: Angle {
            switch directionType {
            case .edge:
                switch edge {
                case .top:
                    return .degrees(90)
                case .leading:
                    return .degrees(0)
                case .bottom:
                    return .degrees(270)
                case .trailing:
                    return .degrees(180)
                }
            case .angle:
                return angle
            }
        }

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wipe")
                            .bold()

                        Text("""
                        myView.transition(
                            .movingParts.wipe(edge: .leading)
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

                    Toggle("Right To Left", isOn: $isRightToLeft)

                    if #available(iOS 16.0, *) {
                        Picker("Type", selection: $directionType) {
                            ForEach(DirectionType.allCases) { type in
                                Text(type.name).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)

                        switch directionType {
                        case .edge:
                            LabeledContent("Edge") {
                                Picker("Edge", selection: $edge) {
                                    Group {
                                        Text("Leading").tag(Edge.leading)
                                        Text("Trailing").tag(Edge.trailing)
                                        Text("Top").tag(Edge.top)
                                        Text("Bottom").tag(Edge.bottom)
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(height: 44)
                        case .angle:
                            LabeledContent("Angle") {
                                AngleControl(angle: $angle)
                            }
                            .frame(height: 44)
                        }

                        LabeledContent("Reference") {
                            Image(systemName: "arrow.forward.circle")
                                .imageScale(.large)
                                .rotationEffect(resolvedAngle)
                                .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
                        }
                    }

                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible())
                    ]

                    LazyVGrid(columns: columns) {
                        ForEach(indices, id: \.self) { uuid in
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor)

                                Text("Hello\nWorld!")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(.title, design: .rounded))

                            }
                            .transition(
                                makeTransition().animation(.easeInOut)
                            )
                            .aspectRatio(1.5, contentMode: .fit)
                            .id(uuid)
                        }
                    }
                    .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)

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
