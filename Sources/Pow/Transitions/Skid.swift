import SwiftUI
#if os(iOS) && EMG_PREVIEWS
import SnapshotPreferences
#endif

public extension AnyTransition.MovingParts {
    /// The direction from which to animate in during a `skid` transition's insertion.
    enum SkidDirection {
        case leading
        case trailing
    }

    /// A transition that moves the view in from its leading edge with any
    /// overshoot resulting in an elastic deformation of the view.
    static var skid: AnyTransition {
        skid(direction: .leading)
    }

    /// A transition that moves the view in from the specified edge during
    /// insertion and towards it during removal with any overshoot resulting
    /// in an elastic deformation of the view.
    ///
    /// - Parameter direction: The direction of the transition.
    static func skid(direction: SkidDirection) -> AnyTransition {
        .modifier(
            active:   Scaled(Skid(direction, animatableData: 0)),
            identity: Scaled(Skid(direction, animatableData: 1))
        )
    }
}

internal struct Skid: Animatable, GeometryEffect {
    var direction: AnyTransition.MovingParts.SkidDirection

    var animatableData: CGFloat = 0

    internal init(_ direction: AnyTransition.MovingParts.SkidDirection, animatableData: CGFloat = 0) {
        self.animatableData = animatableData
        self.direction = direction
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let deltaX = -size.width * 2 * (1 - animatableData)

        var t = CGAffineTransform.identity

        t = t.translatedBy(x: size.width / 2, y: size.height / 2)

        let clampedDeltaX = deltaX

        switch direction {
        case .leading:
            t = t.translatedBy(x: clampedDeltaX, y: 0)
        case .trailing:
            t = t.translatedBy(x: -clampedDeltaX, y: 0)
        }

        let newMainAxisSize = clamp(size.width / 2, size.width - deltaX, size.width * 1.5)

        switch direction {
        case .leading:
            t = t.translatedBy(x: -size.width * (-1 + (newMainAxisSize / size.width)), y: 0)
            t = CGAffineTransformShear(t, -1 + (newMainAxisSize / size.width), 0)
        case .trailing:
            t = t.translatedBy(x: -size.width * (1 - (newMainAxisSize / size.width)), y: 0)
            t = CGAffineTransformShear(t, 1 - (newMainAxisSize / size.width), 0)
        }

        t = t.translatedBy(x: -size.width / 2, y: -size.height / 2)

        return ProjectionTransform(t)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Skid_Previews: PreviewProvider {
    struct Item: Identifiable {
        var color: Color

        let id: UUID = UUID()

        init() {
            color = [Color.red, .orange, .yellow, .green, .indigo, .teal].randomElement()!
        }
    }

    struct Preview: View {
        @State
        var items: [Item] = [Item()]

        @State
        var damping: Double = 0.66

        @State
        var direction: AnyTransition.MovingParts.SkidDirection = .leading

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Skid")
                            .bold()

                        Text("myView.transition(**.movingParts.skid**)\n  .animation(.interactiveSpring(\n    dampingFraction: \(damping.formatted(.number.precision(.fractionLength(2))))\n  )\n)")
                    }
                        .font(.footnote.monospaced())
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.thickMaterial)
                        )

                    Slider(value: $damping, in: 0.2 ... 0.8)

                    Stepper("Count") {
                        withAnimation {
                            items.append(Item())
                        }
                    } onDecrement: {
                        withAnimation {
                            if !items.isEmpty {
                                items.removeLast()
                            }
                        }
                    }

                    if #available(iOS 16.0, *) {
                        LabeledContent("Direction") {
                            Picker("Direction", selection: $direction) {
                                Group {
                                    Label("Leading",  systemImage: "arrow.forward").tag(AnyTransition.MovingParts.SkidDirection.leading)
                                    Label("Trailing", systemImage: "arrow.backward").tag(AnyTransition.MovingParts.SkidDirection.trailing)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    let columns: [GridItem] = [
                        .init(.flexible()),
                        .init(.flexible()),
                        .init(.flexible())
                    ]

                    LazyVGrid(columns: columns) {
                        ForEach(items) { item in
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(item.color)
                                .overlay {
                                    Text("Jell-O\nWorld")
                                        .blendMode(.difference)
                                        .offset(x: 2, y: 2)
                                }
                                .compositingGroup()
                                .overlay {
                                    Text("Jell-O\nWorld")
                                }
                                .font(.system(.headline, design: .rounded).weight(.black))
                                .multilineTextAlignment(.center)
                                .transition(
                                    .asymmetric(
                                        insertion: .movingParts.skid(direction: direction)
                                            .animation(.spring(dampingFraction: damping).speed(0.6))
                                            .combined(with: .opacity.animation(.easeOut(duration: 0.01))),
                                        removal: .opacity
                                    )
                                )
                                .aspectRatio(1, contentMode: .fit)
                                .id(item.id)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }

    static var previews: some View {
        NavigationView {
            Preview()
                .navigationBarHidden(true)
        }
        .environment(\.colorScheme, .dark)
        #if os(iOS) && EMG_PREVIEWS
          .emergeSnapshotPrecision(0)
        #endif
    }
}

@available(iOS 15.0, *)
struct Skid_2_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var isVisible: Bool = false

        @State
        var isRightToLeft: Bool = true

        var body: some View {
            VStack {
                Toggle("Visible", isOn: $isVisible.animation())

                Toggle("Right To Left", isOn: $isRightToLeft)

                if #available(iOS 16.0, *) {
                    LabeledContent("Reference") {
                        Image(systemName: "arrow.forward.circle")
                            .imageScale(.large)
                    }
                } else {
                    HStack {
                        Text("Reference")
                        Spacer()
                        Image(systemName: "arrow.forward.circle")
                            .imageScale(.large)
                    }
                }

                Spacer()

                let overshoot = Animation.movingParts.overshoot(duration: 0.3)
                let mediumSpring = Animation.interactiveSpring(dampingFraction: 0.5)
                let looseSpring = Animation.interpolatingSpring(stiffness: 100, damping: 8)

                Group {
                    if isVisible {
                        Color.blue
                            .frame(width: 120, height: 120)
                            .transition(.movingParts.skid(direction: .leading).animation(overshoot))

                        Color.blue
                            .frame(width: 120, height: 120)
                            .transition(.movingParts.skid(direction: .leading).animation(mediumSpring))

                        Color.blue
                            .frame(width: 120, height: 120)
                            .transition(.movingParts.skid(direction: .trailing).animation(looseSpring))

                        Color.blue
                            .frame(width: 120, height: 120)
                            .transition(.movingParts.move(edge: .leading).animation(looseSpring))
                    }
                }

                Spacer()
            }
            .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
            .padding()
            .background {
                Color.white.ignoresSafeArea()
            }
        }
    }

    static var previews: some View {
        NavigationView {
            Preview()
        }
    }
}
#endif

private extension CGAffineTransform {
    init(skewX x: CGFloat, y: CGFloat) {
        self.init(a: 1, b: x, c: y, d: 1, tx: 0, ty: 0)
    }
}
