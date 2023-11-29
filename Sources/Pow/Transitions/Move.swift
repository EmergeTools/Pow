import SwiftUI
import simd

public extension AnyTransition.MovingParts {
    /// A transition that moves the view from the specified edge of the on
    /// insertion and towards it on removal.
    static func move(edge: Edge) -> AnyTransition {
        return .modifier(
            active: Scaled(Move(edge: edge)),
            identity: Scaled(Move())
        )
    }

    /// A transition that moves the view at the specified angle.
    ///
    /// The angle is relative to the current `layoutDirection`, such that 0° represents animating towards the trailing edge on insertion and 90° represents inserting towards the bottom edge.
    ///
    /// In this example, the view insertion is animated by moving it towards the top trailing corner and the removal is animated by moving it towards the bottom edge.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .transition(
    ///         .asymmetric(
    ///             insertion: .movingParts.move(angle: .degrees(45)),
    ///             removal:   .movingParts.move(angle: .degrees(90))
    ///         )
    ///     )
    /// ```
    ///
    /// - Parameter angle: The direction of the animation.
    static func move(angle: Angle) -> AnyTransition {
        return .modifier(
            active: Scaled(Move(angle: angle)),
            identity: Scaled(Move())
        )
    }
}

internal struct Move: GeometryEffect, Animatable {
    /// Translation is relative, depth is ignored, anchor is always
    /// `UnitPoint(0.5, 0.5)`.
    var animatableData: TRS = .identity

    init(edge: Edge) {
        switch edge {
        case .top:
            animatableData.translation.y = -1
        case .leading:
            animatableData.translation.x = -1
        case .bottom:
            animatableData.translation.y =  1
        case .trailing:
            animatableData.translation.x =  1
        }
    }

    init() {}

    init(angle: Angle) {
        let u = cos(angle.radians)
        let v = sin(angle.radians)

        let u_2: Double = pow(u, 2)
        let v_2: Double = pow(v, 2)
        let sq2: Double = sqrt(2.0)

        let x: Double = 0.5 * sqrt(abs(2.0 + u_2 - v_2 + 2.0 * u * sq2)) - 0.5 * sqrt(abs(2.0 + u_2 - v_2 - 2.0 * u * sq2))
        let y: Double = 0.5 * sqrt(abs(2.0 - u_2 + v_2 + 2.0 * v * sq2)) - 0.5 * sqrt(abs(2.0 - u_2 + v_2 - 2.0 * v * sq2))

        animatableData.translation.x = -x
        animatableData.translation.y = -y
    }

    private var trs: TRS {
        get { animatableData }
        set { animatableData = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let anchor = UnitPoint.center

        let offset = simd_double4x4(translationX: size.width * anchor.x, y: size.height * anchor.y)

        let translation = simd_double4x4(translationX: trs.translation.x * size.width, y: trs.translation.y * size.height, z: 0)

        let rotation = simd_double4x4(trs.rotation.normalized)

        let scale = simd_double4x4(scaleX: trs.scale.x, y: trs.scale.y, z: 1)

        return ProjectionTransform((((offset * translation) * rotation) * scale) * offset.inverse)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Move_Previews: PreviewProvider {
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
        var isRightToLeft: Bool = false

        func makeTransition() -> AnyTransition {
            switch directionType {
            case .edge:
                return .movingParts.move(edge: edge)
            case .angle:
                return .movingParts.move(angle: angle)
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
                        Text("Swoosh")
                            .bold()

                        Text("myView.transition(**.movingParts.move**)")
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
                        withAnimation(.spring()) {
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
                                makeTransition().combined(with: .opacity)
                            )
                            .aspectRatio(1.1, contentMode: .fit)
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
