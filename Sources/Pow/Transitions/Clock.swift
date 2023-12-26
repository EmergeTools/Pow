import SwiftUI
#if os(iOS) && EMG_PREVIEWS
import SnapshotPreferences
#endif

public extension AnyTransition.MovingParts {
    /// A transition using a clockwise sweep around the centerpoint of the view.
    static var clock: AnyTransition {
        clock(blurRadius: 0)
    }

    /// A transition using a clockwise sweep around a point in the view.
    ///
    /// - Parameter origin: The centerpoint of the sweep.
    /// - Parameter blurRadius: The radius of the blur applied to the mask.
    static func clock(origin: UnitPoint = .center, blurRadius: CGFloat) -> AnyTransition {
        .modifier(
            active:   Clock(origin: origin, blurRadius: blurRadius, progress: 0),
            identity: Clock(origin: origin, blurRadius: blurRadius, progress: 1)
        )
    }
}

internal struct Clock: ViewModifier, Animatable, AnimatableModifier {
    var origin: UnitPoint

    var animatableData: AnimatablePair<CGFloat, CGFloat>

    init(origin: UnitPoint, blurRadius: CGFloat, progress: CGFloat) {
        self.origin = origin
        self.animatableData = AnimatableData(progress, blurRadius)
    }

    var progress: CGFloat {
        animatableData.first
    }

    var blurRadius: CGFloat {
        animatableData.second
    }

    @Environment(\.layoutDirection)
    var layoutDirection

    func body(content: Content) -> some View {
        let blurProgress = 1 - pow(2, 15 * (progress - 1))

        content
            .mask(
                Circle(unitPoint: origin, layoutDirection: layoutDirection)
                    .trim(from: 0, to: clamp(progress * 1.05))
                    .padding(-blurRadius * blurProgress)
                    .blur(radius: blurRadius * blurProgress)
            )
    }

    private struct Circle: Shape {
        var unitPoint: UnitPoint

        var layoutDirection: LayoutDirection

        func path(in rect: CGRect) -> Path {
            let origin = CGPoint(
                x: layoutDirection == .rightToLeft
                    ? rect.maxX - rect.width * unitPoint.x
                    : rect.minX + rect.width * unitPoint.x,
                y: rect.minY + rect.height * unitPoint.y
            )

            let (startAngle, endAngle) = rect.clockStartAndEndAngles(for: origin)

            return Path { path in
                path.move(to: origin)
                path.addArc(
                    center: origin,
                    radius: rect.diagonal / 2 + origin.distance(to: rect.center),
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
            }
        }
    }
}

#if os(iOS) && DEBUG
struct Clock_Previews: PreviewProvider {
    struct Item: Identifiable {
        var color: Color

        let id: UUID = UUID()

        init() {
            color = [Color.red, .orange, .yellow, .green, .purple, .mint].randomElement()!
        }
    }

    struct Preview: View {
        @State
        var items: [Item] = [Item()]

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
                        Text("Clock Wipe")
                            .bold()

                        Text("myView.transition(**.movingParts.clock**)")
                    }
                        .font(.footnote.monospaced())
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.thickMaterial)
                        )

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
                        ForEach(items) { item in
                            filledShape(color: item.color)
                                .transition(.movingParts.clock(origin: .init(x: originX, y: originY), blurRadius: 10))
                                .aspectRatio(1/1.4, contentMode: .fit)
                                .id(item.id)
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
        .environment(\.colorScheme, .dark)
        #if os(iOS) && EMG_PREVIEWS
          .emergeSnapshotPrecision(0)
        #endif
    }
}
#endif

private extension CGRect {
    func clockStartAndEndAngles(for point: CGPoint) -> (start: Angle, end: Angle) {
        if point.x <= minX {
            if point.y <= minY {
                // topLeft
                return (
                    start: point.angle(to: topRight),
                    end: point.angle(to: bottomLeft)
                )
            } else if point.y >= maxY {
                // bottomLeft
                return (
                    start: point.angle(to: topLeft),
                    end: point.angle(to: bottomRight)
                )
            } else {
                // left
                return (
                    start: point.angle(to: topLeft),
                    end: point.angle(to: bottomLeft)
                )
            }
        } else if point.x >= maxX {
            if point.y <= 0.0 {
                // topRight
                return (
                    start: point.angle(to: bottomRight),
                    end: point.angle(to: topLeft)
                )
            } else if point.y >= maxY {
                // bottomRight
                return (
                    start: point.angle(to: bottomLeft),
                    end: point.angle(to: topRight)
                )
            } else {
                // right
                return (
                    start: point.angle(to: bottomRight),
                    end: point.angle(to: topRight)
                )
            }
        } else {
            if point.y <= minY {
                // top
                return (
                    start: point.angle(to: topRight),
                    end: point.angle(to: topLeft)
                )
            } else if point.y >= maxY {
                // bottom
                return (
                    start: point.angle(to: bottomLeft),
                    end: point.angle(to: bottomRight)
                )
            } else {
                // center
                return (
                    start: .degrees(0) - .degrees(90),
                    end: .degrees(360) - .degrees(90)
                )
            }
        }
    }
}
