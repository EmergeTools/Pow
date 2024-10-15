import SwiftUI
import simd

#if !os(watchOS)
public extension AnyTransition.MovingParts {
    /// A three-dimensional transition from the back of the towards the front
    /// during insertion and from the front towards the back during removal.
    static var swoosh: AnyTransition {
        return .modifier(
            active: Transform3DEffect(
                translation: [-100, -50, -2500],
                rotation:
                    simd_quatd(angle: Angle(degrees: -85).radians, axis: [1, 0, 0]) *
                    simd_quatd(angle: Angle(degrees:  45).radians, axis: [0, 1, 0]) *
                    simd_quatd(angle: Angle(degrees:  10).radians, axis: [0, 0, 1])
                ,
                anchor: .top,
                anchorZ: -20,
                perspective: 0.16
            ),
            identity: Transform3DEffect(perspective: 0.16)
        )
    }
}
#endif

#if os(iOS) && DEBUG
@available(iOS 15.0, *)
struct Swoosh_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Swoosh")
                            .bold()

                        Text("myView.transition(**.movingParts.swoosh**)")
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
                        withAnimation(.spring(dampingFraction: 0.8)) {
                            indices.append(UUID())
                        }
                    } onDecrement: {
                        if !indices.isEmpty {
                            let _ = withAnimation {
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
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor)

                                Text("Hello\nWorld!")
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(.title, design: .rounded))

                            }
                            .transition(
                                .movingParts.swoosh.combined(with: .opacity)
                            )
                            .aspectRatio(1.1, contentMode: .fit)
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
