import SwiftUI

struct AngleControl<Label: View>: View {
    @Binding
    var angle: Angle

    var label: Label

    init(angle: Binding<Angle>, @ViewBuilder label: () -> Label) {
        self._angle = angle
        self.label = label()
    }

    @State
    private var lastAngle: Angle = .zero

    @GestureState
    private var dragAngle: Angle = .zero

    @Environment(\.controlSize)
    private var controlSize

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragAngle) { value, state, _ in
                state = .degrees(-value.translation.height * 2)
            }
            .onChanged { value in
                angle = lastAngle + .degrees(-value.translation.height * 2)
            }
            .onEnded { value in
                angle = lastAngle + .degrees(-value.translation.height * 2)
                lastAngle = angle
            }
    }

    private var size: CGFloat {
        switch controlSize {
        case .mini: return 32
        case .small: return 38
        case .regular: return 44
        case .large: return 54
        case .extraLarge: return 54
        @unknown default: return 44
        }
    }

    var body: some View {
        let content = ZStack {
            Circle()
                .fill(.gray.opacity(dragAngle == .zero ? 0.1 : 0.2))
                .animation(.easeOut(duration: dragAngle == .zero ? 0.3 : 0.05), value: dragAngle == .zero)
            Circle()
                .stroke(.quaternary)
            ZStack(alignment: .leading) {
                Color.clear
                Capsule(style: .continuous)
                    .fill(.tint)
                    .frame(width: size / 4, height: 2)
                    .padding(4)
            }
            .rotationEffect(angle)
        }
        .frame(width: size, height: size)

        if #available(iOS 16.0, macOS 13, *) {
            LabeledContent {
                content
            } label: {
                label
            }
            .gesture(dragGesture)
        } else {
            content
                .gesture(dragGesture)
        }
    }
}

extension AngleControl where Label == Text {
    init(_ title: some StringProtocol, angle: Binding<Angle>) {
        self._angle = angle
        self.label = Text(title)
    }

    init(_ titleKey: LocalizedStringKey, angle: Binding<Angle>) {
        self._angle = angle
        self.label = Text(titleKey)
    }

    init(angle: Binding<Angle>) {
        self._angle = angle
        let measurement = Measurement<UnitAngle>(value: angle.wrappedValue.degrees, unit: .degrees)
        let formatted = measurement
            .formatted(
                .measurement(
                    width: .narrow,
                    numberFormatStyle: .number.precision(.fractionLength(0))
                )
            )
        self.label = Text(formatted)
    }
}

struct AngleControl_Previews: PreviewProvider {
    struct Preview: View {
        @State var angle: Angle = .zero

        var body: some View {
            VStack {
                Rectangle()
                    .fill(.red)
                    .frame(width: 100, height: 1)
                    .rotationEffect(angle)

                AngleControl(angle: $angle)
            }
            .monospacedDigit()
        }
    }

    static var previews: some View {
        VStack(spacing: 32) {
            ForEach(ControlSize.allCases, id: \.self) { size in
                Preview()
                    .controlSize(size)
            }
        }
        .padding()
    }
}
