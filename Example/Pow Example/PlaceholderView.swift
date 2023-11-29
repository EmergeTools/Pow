import SwiftUI

struct PlaceholderView: View {
    var hiddenContent: Bool

    init(hiddenContent: Bool = false) {
        self.hiddenContent = hiddenContent
    }

    var gridLines: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1)
                .padding()
            Circle()
                .stroke(lineWidth: 1)
                .padding()
                .padding()
                .padding()
                .padding()
            HStack {
                ForEach(0..<5) { _ in
                    Spacer()
                    Rectangle().frame(width: 1)
                }
                Spacer()
            }
            VStack {
                Spacer()
                Rectangle().frame(height: 1)
                Spacer()
                Rectangle().frame(height: 1)
                Spacer()
                Rectangle().frame(height: 1)
                Spacer()
                Rectangle().frame(height: 1)
                Spacer()
            }
        }
        .overlay {
            Rectangle().frame(width: 1, height: 500)
                .rotationEffect(.degrees(45))
            Rectangle().frame(width: 1, height: 500)
                .rotationEffect(.degrees(-45))
        }
    }

    var fillColors: [Color] {
        if !hiddenContent {
            return [
                Color(.displayP3, red: 0.32, green: 0.61, blue: 0.97),
                Color(.displayP3, red: 0.20, green: 0.47, blue: 0.96)
            ]
        } else {
            return [
                Color(.displayP3, white: 0.25),
                Color(.displayP3, white: 0.3)
            ]
        }
    }

    @ViewBuilder
    var fill: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(LinearGradient(colors: fillColors, startPoint: .top, endPoint: .bottom))
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(.black.opacity(0.3), lineWidth: 4)
            }
    }

    var body: some View {
        fill
            .overlay {
                gridLines
                    .opacity(0.25)
                    .scaledToFill()
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .font(
                Font
                    .system(.largeTitle)
                    .bold()
                    .leading(.tight)
            )
            .multilineTextAlignment(.center)
            .environment(\.dynamicTypeSize, .xxLarge)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .compositingGroup()
            .frame(maxWidth: 250, maxHeight: 250)
    }
}
