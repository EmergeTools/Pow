import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition that takes the shape of a growing circle when inserting,
    /// and a shrinking circle when removing.
    ///
    /// - Parameters:
    ///   - origin: The center point of the circle as it grows or shrinks.
    ///   - blurRadius: The radius of the blur applied to the mask.
    static func iris(origin: UnitPoint = .center, blurRadius: CGFloat = 0) -> AnyTransition {
        .modifier(
            active: Iris(origin: origin, blurRadius: blurRadius, animatableData: 0),
            identity: Iris(origin: origin, blurRadius: blurRadius, animatableData: 1)
        )
    }
}

private struct Iris: ViewModifier, Animatable, AnimatableModifier {
    var origin: UnitPoint

    var blurRadius: CGFloat

    var animatableData: CGFloat = 0

    internal init(origin: UnitPoint, blurRadius: CGFloat = 0, animatableData: CGFloat) {
        self.origin = origin
        self.blurRadius = clamp(0, blurRadius, 30)
        self.animatableData = animatableData
    }

    var progress: CGFloat {
        get { animatableData }
        set { animatableData = newValue }
    }

    func body(content: Content) -> some View {
        content
            .mask(
                GeometryReader { proxy in
                    let width  = proxy.size.width
                    let height = proxy.size.height

                    let scaledWidth  = width  * 2 * max(origin.x, 1 - origin.x)
                    let scaledHeight = height * 2 * max(origin.y, 1 - origin.y)

                    let diagonal = progress * sqrt(scaledWidth * scaledWidth + scaledHeight * scaledHeight)

                    Circle()
                        .frame(width: diagonal, height: diagonal)
                        .position(
                            x: origin.x * width,
                            y: origin.y * height
                        )
                        .blur(radius: (1 - progress) * blurRadius)
                }
            )
    }
}

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Mask_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        enum ShapeType: String, Hashable, Identifiable, CaseIterable {
            case rectangle = "Rectangle"
            case roundedRectangle = "Rounded Rectangle"
            case capsule = "Capsule"
            case circle = "Circle"

            var name: String {
                return rawValue
            }

            var id: Self {
                return self
            }

            var symbolName: String {
                switch self {
                case .rectangle:
                    return "rectangle.fill"
                case .roundedRectangle:
                    return "rectangle.roundedtop.fill"
                case .capsule:
                    return "capsule.fill"
                case .circle:
                    return "circle.fill"
                }
            }
        }

        @State
        var selectedShape: ShapeType = .roundedRectangle

        @ViewBuilder
        func filledShape(color: Color) -> some View {
            switch selectedShape {
            case .rectangle:
                Rectangle().fill(color)
            case .roundedRectangle:
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(color)
            case .capsule:
                Capsule().fill(color)
            case .circle:
                Circle().fill(color)
            }
        }

        @State
        var originX: CGFloat = 0.5

        @State
        var originY: CGFloat = 0.5

        @State
        var blurRadius: CGFloat = 0

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Flip")
                            .bold()

                        Text("myView.transition(.movingParts.iris())")
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
                        LabeledContent("Shape") {
                            Picker("Shape", selection: $selectedShape) {
                                ForEach(ShapeType.allCases) { shapeType in
                                    Label(shapeType.name,  systemImage: shapeType.symbolName).tag(shapeType)
                                }
                            }
                        }
                        .pickerStyle(.menu)

                        LabeledContent("Origin") {
                            Text(originX, format: .number.precision(.fractionLength(2))) +
                            Text("×") +
                            Text(originY, format: .number.precision(.fractionLength(2)))
                        }
                        Slider(value: $originX, in: -0.5...1.5)
                        Slider(value: $originY, in: -0.5...1.5)
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
                            .transition(
                                .asymmetric(
                                    insertion: .movingParts.iris(origin: .init(x: originX, y: originY), blurRadius: blurRadius),
                                    removal: .movingParts.iris(origin: .init(x: originX, y: originY), blurRadius: blurRadius)
                                )
                            )
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
