import SwiftUI

struct GithubButton: View {
    var localPath: LocalPath

    let baseURL = URL(string: "https://github.com/movingparts-io/Pow-Examples/blob/main/")!

    init(_ localPath: LocalPath) {
        self.localPath = localPath
    }

    var body: some View {
        let srcroot = Bundle.main.object(forInfoDictionaryKey: "MVP_SRCROOT") as? String

        if let srcURL = srcroot.map(URL.init(fileURLWithPath:)) {
            let relative = localPath.url.relativePath(to: srcURL)

            let url = baseURL.appendingPathComponent(relative)

            Link(destination: url) {
                ViewThatFits {
                    Label("Show Example on GitHub", systemImage: "terminal")
                    Label("Show on GitHub", systemImage: "terminal")
                }
            }
        }
    }
}

private extension URL {
    func relativePath(to base: URL) -> String {
        let pathComponents = self.pathComponents
        let baseComponents = base.pathComponents

        guard pathComponents.starts(with: baseComponents) else {
            fatalError("\(self) is not contained inside \(base).")
        }

        return pathComponents
            .dropFirst(baseComponents.count)
            .joined(separator: "/")
    }
}
