import Pow
import SwiftUI

struct MoveExample: View, Example {
    @State
    var angle: Angle = .degrees(225)

    @State
    var isVisible: Bool = false

    var body: some View {
        VStack {
            GroupBox {
                LabeledContent {
                    Slider(value: $angle.degrees, in: 0 ... 360, step: 5)
                } label: {
                    Text("Angle")
                    Spacer()
                    Text(Measurement(value: angle.degrees, unit: UnitAngle.degrees).formatted(.measurement(width: .narrow, numberFormatStyle: .number.precision(.fractionLength(0)))))
                        .foregroundColor(.secondary)
                        .font(.subheadline.monospacedDigit())
                }
            }
            .padding(.horizontal)

            VStack {
                if isVisible {
                    PlaceholderView()
                        .compositingGroup()
                        .transition(.movingParts.move(angle: angle).combined(with: .opacity))
                }
            }
            .defaultBackground()
            .onTapGesture {
                withAnimation(.spring(dampingFraction: 1)) {
                    isVisible.toggle()
                }
            }
        }
        .labeledContentStyle(VerticalLabeledContentStyle())
        .defaultBackground()
        .autotoggle($isVisible, with: .spring(dampingFraction: 1))
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
    }
}

private struct VerticalLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                configuration.label
            }

            configuration.content
        }
    }
}
