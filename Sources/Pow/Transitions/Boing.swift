import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition that moves the view down with any overshoot resulting in an
    /// elastic deformation of the view.
    static var boing: AnyTransition {
        boing(edge: .top)
    }

    /// A transition that moves the view from the specified edge on insertion,
    /// and towards it on removal, with any overshoot resulting in an elastic
    /// deformation of the view.
    static func boing(edge: Edge) -> AnyTransition {
        .modifier(
            active:   Scaled(Boing(edge, animatableData: 0)),
            identity: Scaled(Boing(edge, animatableData: 1))
        )
    }
}

internal struct Boing: Animatable, GeometryEffect {
    var edge: Edge

    var animatableData: CGFloat = 0

    internal init(_ edge: Edge, animatableData: CGFloat = 0) {
        self.animatableData = animatableData
        self.edge = edge
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let area = size.width * size.height

        var mainAxisSize: CGFloat {
            edge == .leading || edge == .trailing ? size.width : size.height
        }

        var crossAxisSize: CGFloat {
            edge == .leading || edge == .trailing ? size.height : size.width
        }

        let deltaP = -mainAxisSize * 2 * (1 - animatableData)

        var t = CGAffineTransform.identity

        if deltaP < 1 {
            let newMainAxisSize = rubberClamp(mainAxisSize / 2, mainAxisSize - deltaP / 3, mainAxisSize * 1.5)
            let newCrossAxisSize = area / newMainAxisSize

            t = t.translatedBy(x: size.width / 2, y: size.height / 2)

            switch edge {
            case .top:
                t = t.translatedBy(x: 0, y: deltaP)
            case .bottom:
                t = t.translatedBy(x: 0, y: -deltaP)
            case .leading:
                t = t.translatedBy(x: deltaP, y: 0)
            case .trailing:
                t = t.translatedBy(x: -deltaP, y: 0)
            }

            if edge == .leading || edge == .trailing {
                t = t.scaledBy(x: newMainAxisSize / mainAxisSize, y: newCrossAxisSize / crossAxisSize)
            } else {
                t = t.scaledBy(x: newCrossAxisSize / crossAxisSize, y: newMainAxisSize / mainAxisSize)
            }

            t = t.translatedBy(x: -size.width / 2, y: -size.height / 2)
        }

        if deltaP >= 5 {
            let deltaY = deltaP - 5

            let newMainAxisSize = rubberClamp(mainAxisSize * 0.75, mainAxisSize - deltaY / 3, mainAxisSize * 1)
            let newCrossAxisSize  = area / newMainAxisSize

            let translation: CGAffineTransform

            switch edge {
            case .top:
                translation = CGAffineTransformMakeTranslation(size.width / 2, size.height)
            case .leading:
                translation = CGAffineTransformMakeTranslation(size.width, size.height / 2)
            case .bottom:
                translation = CGAffineTransformMakeTranslation(size.width / 2, 0)
            case .trailing:
                translation = CGAffineTransformMakeTranslation(0, size.height / 2)
            }

            t = translation.concatenating(t)

            if edge == .leading || edge == .trailing {
                t = t.scaledBy(x: newMainAxisSize / mainAxisSize, y: newCrossAxisSize / crossAxisSize)
            } else {
                t = t.scaledBy(x: newCrossAxisSize / crossAxisSize, y: newMainAxisSize / mainAxisSize)
            }

            t = translation.inverted().concatenating(t)
        }

        return ProjectionTransform(t)
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Bounce_Previews: PreviewProvider {
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
        var damping: Double = 0.5

        @State
        var edge: Edge = .top

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Boing")
                            .bold()

                        Text("myView.transition(**.movingParts.boing**)\n  .animation(.interactiveSpring(\n    dampingFraction: \(damping.formatted(.number.precision(.fractionLength(2))))\n  )\n)")
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
                            var item = Item()
                            item.color = [Color.red, .orange, .yellow, .green, .indigo, .teal].shuffled().first { color in
                                !items.contains { $0.color == color }
                            } ?? .blue

                            items.append(item)
                        }
                    } onDecrement: {
                        if !items.isEmpty {
                            items.removeLast()
                        }
                    }

                    if #available(iOS 16.0, *) {
                        LabeledContent("Edge") {
                            Picker("Edge", selection: $edge) {
                                Group {
                                    Label("Leading",  systemImage: "arrow.forward").tag(Edge.leading)
                                    Label("Trailing", systemImage: "arrow.backward").tag(Edge.trailing)
                                    Label("Top",      systemImage: "arrow.down").tag(Edge.top)
                                    Label("Bottom",   systemImage: "arrow.up").tag(Edge.bottom)
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
                                    .movingParts.boing(edge: edge)
                                        .animation(.spring(dampingFraction: damping))
                                        .combined(with: .opacity.animation(.easeOut(duration: 0.01)))
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
    }
}

@available(iOS 15.0, *)
struct Boing_2_Previews: PreviewProvider {
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
                            .transition(.movingParts.boing(edge: .leading).animation(overshoot))

                        Color.blue
                            .frame(width: 120, height: 120)
                            .transition(.movingParts.boing(edge: .leading).animation(mediumSpring))

                        Color.blue
                            .frame(width: 120, height: 120)
                            .transition(.movingParts.boing(edge: .trailing).animation(looseSpring))

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
