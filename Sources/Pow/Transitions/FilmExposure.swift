import SwiftUI

public extension AnyTransition.MovingParts {
    /// A transition from completely dark to fully visible on insertion, and
    /// from fully visible to completely dark on removal.
    static var filmExposure: AnyTransition {
        .modifier(
            active:   ExposureFade(animatableData: 0),
            identity: ExposureFade(animatableData: 1)
        )
    }

    /// A transition from completely bright to fully visible on insertion, and
    /// from fully visible to completely bright on removal.
    static var snapshot: AnyTransition {
        .modifier(
            active:   Snapshot(animatableData: 0),
            identity: Snapshot(animatableData: 1)
        )
    }
}

internal struct Snapshot: ViewModifier, ProgressableAnimation, AnimatableModifier, Hashable {
    var animatableData: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .saturation(0.5 + 0.5 * clamp(progress))
            .contrast(0.5 + 0.5 * clamp(progress))
            .brightness(0.85 * (1.0 - clamp(1 * progress)))
            .blur(radius: 5.0 * (1.0 - clamp(progress)), opaque: true)
            .animation(nil, value: progress)
    }
}

internal struct ExposureFade: ViewModifier, ProgressableAnimation, AnimatableModifier, Hashable {
    var animatableData: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .opacity(Double(1.0 - pow(2.0, -10.0 * progress)))
            .brightness(-1.0 * (1.0 - clamp(progress)))
            .animation(nil, value: progress)
    }
}

#if os(iOS) && DEBUG
struct Snapshot_Preview: PreviewableAnimation, PreviewProvider {
  static var animation: Snapshot {
    Snapshot(animatableData: 0)
  }
}

struct FilmExposure_Preview: PreviewableAnimation, PreviewProvider {
  static var animation: ExposureFade {
    ExposureFade(animatableData: 0)
  }
}

@available(iOS 15.0, *)
struct ExoposureFade_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var url: URL = URL(string: "https://picsum.photos/500")!

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Snapshot")
                            .bold()

                        Text("myView.transition(\n    .movingParts.snapshot\n)")
                    }
                    .font(.footnote.monospaced())
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.thickMaterial)
                    )

                    AsyncImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 1.8))) { phase in
                        ZStack {
                            Color.black

                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .id(UUID())
                                    .transition(.movingParts.snapshot)
                            case .failure(let error):
                                Text(error.localizedDescription)
                                    .font(.caption)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .environment(\.colorScheme, .dark)
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button {
                        url = [
                            URL(string: "https://picsum.photos/400")!,
                            URL(string: "https://picsum.photos/420")!,
                            URL(string: "https://picsum.photos/440")!,
                            URL(string: "https://picsum.photos/480")!,
                        ]
                        .filter { $0 != url }
                        .randomElement() ?? url
                    } label: {
                        Label("Shuffle", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

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
    }
}
#endif
