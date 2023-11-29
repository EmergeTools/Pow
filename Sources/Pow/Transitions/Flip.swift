import SwiftUI
import simd

public extension AnyTransition.MovingParts {
    /// A transition that inserts by rotating the view towards the viewer, and
    /// removes by rotating the view away from the viewer.
    ///
    /// - Note: Any overshoot of the animation will result in the view
    ///         continuing the rotation past the view's normal state before
    ///         eventually settling.
    static var flip: AnyTransition {
        .modifier(
            active:   Transform3DEffect(rotation: simd_quatd(angle: Angle(degrees: 90).radians, axis: [1, 0, 0]), perspective: 1 / 6).shaded,
            identity: Transform3DEffect(perspective: 1 / 6).shaded
        )
    }

    /// A transition that inserts by rotating from the specified rotation, and
    /// removes by rotating to the specified rotation in three dimensions.
    ///
    /// In this example, the view is rotated 90˚ about the y axis around
    /// its bottom edge as if it was rising from lying on its back face:
    ///
    /// ```swift
    /// Text("Hello")
    ///     .transition(.movingParts.rotate3D(
    ///         .degrees(90),
    ///         axis: (1, 0, 0),
    ///         anchor: .bottom,
    ///         perspective: 1.0 / 6.0)
    ///     )
    /// ```
    ///
    /// - Note: Any overshoot of the animation will result in the view
    ///         continuing the rotation past the view's normal state before
    ///         eventually settling.
    ///
    /// - Parameters:
    ///   - angle: The angle from which to rotate the view.
    ///   - axis: The x, y and z elements that specify the axis of rotation.
    ///   - anchor: The location with a default of center that defines a point
    ///             in 3D space about which the rotation is anchored.
    ///   - anchorZ: The location with a default of 0 that defines a point in 3D
    ///              space about which the rotation is anchored.
    ///   - perspective: The relative vanishing point with a default of 1 for
    ///                  this rotation.
    static func rotate3D(_ angle: Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint = .center, anchorZ: CGFloat = 0, perspective: CGFloat = 1) -> AnyTransition {
        let active = Transform3DEffect(
            rotation: simd_quatd(angle: angle.radians, axis: [axis.x, axis.y, axis.z]),
            anchor: anchor,
            anchorZ: anchorZ,
            perspective: perspective
        )

        let identity = Transform3DEffect(
            anchor: anchor,
            anchorZ: anchorZ,
            perspective: perspective
        )

        return .modifier(
            active: active.shaded,
            identity: identity.shaded
        )
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Flip_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Flip")
                            .bold()

                        Text("""
                        myView.transition(
                            .transition(.flip)
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
                        let animation = Animation.interpolatingSpring(
                            mass: 1,
                            stiffness: 10,
                            damping: 10,
                            initialVelocity: 10
                        )

                        withAnimation(animation) {
                            indices.append(UUID())
                        }
                    } onDecrement: {
                        if !indices.isEmpty {
                            let _ = withAnimation(.easeInOut) {
                                indices.removeLast()
                            }
                        }
                    }

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
                            .transition(.movingParts.flip)
                            .aspectRatio(1, contentMode: .fit)
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
