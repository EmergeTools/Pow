import Pow
import SwiftUI

struct SocialFeedExample: View, Example {
    @State
    var isLiked = false

    @State
    var isBoosted = false

    @State
    var clapCount = 202

    @State
    var isBookmarked = false

    @State
    var notificationCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 24) {
                HStack(alignment: .top, spacing: 12) {
                    Image("mvp")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: 6) {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Moving Parts").font(.headline.bold())
                                Spacer()

                                Text("12 min")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Text("@movingpartsio").foregroundColor(.secondary)
                        }
                        .padding(.top, 3)

                        Text("Use Pow's Change Effects to give your buttons a little extra flair.")

                        Text("Try it on these buttons here:")
                    }
                }

                ViewThatFits {
                    buttonBar
                        .labelStyle(CustomButtonLabelStyle())

                    buttonBar
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .tint(.gray)
                .font(.footnote.weight(.medium).monospacedDigit())
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(12)
        }
        .task {
            try? await Task.sleep(for: .seconds(3))

            withAnimation {
                notificationCount += 1
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    var buttonBar: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            let pop = SoundEffect("pop1", "pop2", "pop3", "pop4", "pop5")

            Button {
                isLiked.toggle()
            } label: {
                let likeCount = isLiked ? 144: 143

                Label {
                    Text(likeCount.formatted())
                } icon: {
                    Image(systemName: "heart.fill")
                        .changeEffect(
                            .spray {
                                Image(systemName: "heart.fill").foregroundStyle(.red)
                            },
                            value: likeCount,
                            isEnabled: isLiked
                        )
                }
            }
            .tint(isLiked ? .red : .gray)
            .changeEffect(.feedback(pop), value: isLiked, isEnabled: isLiked)

            let sparkle = SoundEffect(isBoosted ? "sparkle.rising" : "sparkle.falling")

            Button {
                isBoosted.toggle()
            } label: {
                let boostCount = isBoosted ? 55 : 54

                Label {
                    Text(boostCount.formatted())
                } icon: {
                    Image(systemName: "arrow.3.trianglepath")
                        .changeEffect(
                            .rise {
                                Text("+1")
                                    .font(.footnote.weight(.heavy))
                                    .shadow(color: .green.opacity(0.5), radius: 1)
                                    .foregroundStyle(.green.gradient)
                            },
                            value: boostCount,
                            isEnabled: isBoosted
                        )
                }
            }
            .tint(isBoosted ? .green : .gray)
            .changeEffect(.feedback(sparkle), value: isBoosted)

            Button {
                clapCount += 1
            } label: {
                Label {
                    Text(clapCount.formatted())
                } icon: {
                    Image(systemName: "hands.clap.fill")
                        .changeEffect(
                            .spray {
                                Group {
                                    Image(systemName: "circle.fill").foregroundColor(.red)
                                    Image(systemName: "square.fill").foregroundColor(.green)
                                    Image(systemName: "circle.fill").foregroundColor(.blue)
                                    Image(systemName: "diamond.fill").foregroundColor(.orange)
                                    Image(systemName: "triangle.fill").foregroundColor(.indigo)
                                }
                                .shadow(radius: 1)
                                .font(.caption.weight(.black))
                            },
                            value: clapCount
                        )
                }
            }
            .changeEffect(.feedback(pop), value: clapCount)
            .tint(clapCount > 202 ? .blue : .gray)

            let pick = SoundEffect(isBookmarked ? "pick.rising" : "pick.falling")

            Button {
                isBookmarked.toggle()
            } label: {
                Label {
                    ZStack {
                        Text("Saved").hidden()
                        Text(isBookmarked ? "Saved" : "Save")
                    }
                } icon: {
                    Image(systemName: "bookmark.fill")
                }
            }
            .tint(isBookmarked ? .orange : .gray)
            .animation(.spring(response: 0.4, dampingFraction: 1), value: isBookmarked)
            .changeEffect(.feedback(pick), value: isBookmarked)
        }
    }

    var tabBar: some View {
        HStack {
            Label("Home", systemImage: "house")
                .labelStyle(SocialFeedTabBarLabelStyle(isSelected: true))

            Label("Search", systemImage: "magnifyingglass")

            Label {
                Text("Notifications")
            } icon: {
                Image(systemName: "bell")
                    .overlay(alignment: .topTrailing) {
                        Text(notificationCount.formatted())
                            .fixedSize()
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.white)
                            .padding(.vertical,   2)
                            .padding(.horizontal, 7)
                            .background(.red, in: Capsule())
                            .changeEffect(.pulse(shape: Capsule(), style: .red, count: 3), value: notificationCount)
                            .alignmentGuide(.top) { dimensions in
                                dimensions[VerticalAlignment.center] - 2
                            }
                            .alignmentGuide(.trailing) { dimensions in
                                dimensions[HorizontalAlignment.center]
                            }
                            .scaleEffect(notificationCount > 0 ? 1 : 0.1)
                            .opacity(notificationCount > 0 ? 1 : 0)
                    }
            }
            .onTapGesture {
                withAnimation {
                    notificationCount += 1
                }
            }

            Label {
                Text("Archive")
            } icon: {
                Image(systemName: "archivebox")
                    .changeEffect(.jump(height: 50), value: isBookmarked, isEnabled: isBookmarked)
            }

            Label("Profile", systemImage: "person")
        }
        .labelStyle(SocialFeedTabBarLabelStyle(isSelected: false))
        .padding(12)
        .padding(.bottom, 2)
        .background(.regularMaterial, in: Capsule(style: .continuous))
        .padding(.horizontal)
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "heart")
    }
}

private struct SocialFeedTabBarLabelStyle: LabelStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 6) {
            configuration.icon
                .imageScale(.medium)
                .symbolVariant(isSelected ? .fill : .none)
                .font(.system(size: 22))
        }
        .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(Color.primary))
        .frame(maxWidth: .infinity)
    }
}

private struct CustomButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon

            configuration.title
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity)
    }
}
