import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition that removes the view in a dissolving cartoon style cloud.
    ///
    /// The transition is only performed on removal and takes 0.4 seconds.
    static var poof: AnyTransition {
        .asymmetric(
            insertion: .identity,
            removal: .modifier(
                active: Poof(animatableData: 0),
                identity: Poof(animatableData: 1)
            )
            .animation(.linear(duration: 0.4))
        )
    }
}

struct Poof: ViewModifier, ProgressableAnimation, AnimatableModifier {
    var animatableData: CGFloat = 0

    internal init(animatableData: CGFloat) {
        self.animatableData = animatableData
    }

    func body(content: Content) -> some View {
        let frame = (6 * progress).rounded()

        content
            .opacity(progress != 1 ? 0 : 1)
            .overlay(
                ZStack {
                    poof("poof1").opacity(frame == 5 ? 1 : 0)
                    poof("poof2").opacity(frame == 4 ? 1 : 0)
                    poof("poof3").opacity(frame == 3 ? 1 : 0)
                    poof("poof4").opacity(frame == 2 ? 1 : 0)
                    poof("poof5").opacity(frame == 1 ? 1 : 0)

                }
                .accessibilityHidden(true)
            )
            .animation(nil, value: progress)
    }

    func poof(_ name: String) -> some View {
        Image(name, bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 88, height: 88)
    }
}

#if os(iOS) && DEBUG
struct Proof_Preview: PreviewableAnimation, PreviewProvider {
  static var animation: Poof {
    Poof(animatableData: 0)
  }

  static var content: any View {
    ZStack {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(Color.accentColor)

        Text("Hello\nWorld!")
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .font(.system(.title, design: .rounded))
    }
    .frame(width: 300, height: 150)
  }
}

@available(iOS 15.0, *)
struct Poof_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var indices: [UUID] = [UUID()]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Poof")
                            .bold()

                        Text("myView.transition(.movingParts.poof)")
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
                                .movingParts.poof
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
