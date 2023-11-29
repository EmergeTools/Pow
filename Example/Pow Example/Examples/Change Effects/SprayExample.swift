import Pow
import SwiftUI

struct SprayExample: View, Example {
    @State
    var isFavorited: Bool = false

    var body: some View {
        ZStack {
            Label {
                let favoriteCount = isFavorited ? 143 : 142

                Text(favoriteCount.formatted())
                    .contentTransition(.numericText())
                    .monospacedDigit()
            } icon: {
                ZStack {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .fontWeight(.light)
                        .opacity(isFavorited ? 0 : 1)

                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink.gradient)
                        .scaleEffect(isFavorited ? 1 : 0.1, anchor: .center)
                        .opacity(isFavorited ? 1 : 0)
                }
                .changeEffect(.spray {
                    Group {
                        Image(systemName: "heart.fill")
                        Image(systemName: "sparkles")
                    }
                    .font(.title)
                    .foregroundStyle(.pink.gradient)
                }, value: isFavorited, isEnabled: isFavorited)
            }
            .padding(.vertical, 8)
            .padding(.leading, 16)
            .padding(.trailing, 24)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.foreground)
                    .opacity(0.3)
            }
            .foregroundStyle(isFavorited ? .pink : .secondary)
            .font(.system(.title, design: .rounded, weight: .semibold))
        }
        .defaultBackground()
        .onTapGesture {
            withAnimation(.movingParts.overshoot(duration: 0.4)) {
                isFavorited.toggle()
            }
        }
    }

    static var description: some View {
        Text("""
        An effect that emits multiple particles in different shades and sizes moving up from the origin point.

        - Parameters:
            - `origin`: The origin of the particles.
            - `particles`: The particles to emit.
        """)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "party.popper")
    }
}
