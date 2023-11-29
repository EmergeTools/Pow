import SwiftUI

@main
struct PowExampleApp: App {
    struct Presentation: Identifiable {
        var type: any Example.Type

        var id: UUID = UUID()
    }

    @State
    var presentedType: Presentation? = nil

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExampleList()
            }
            .environment(\.presentInfoAction, PresentInfoAction {
                presentedType = Presentation(type: $0)
            })
            .sheet(item: $presentedType) { t in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t.type.title).font(.title.bold())

                        GithubButton(t.type.localPath)
                            .controlSize(.small)
                            .buttonStyle(.bordered)

                        t.type.erasedDescription
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .presentationDetents([.medium])
            }
        }
    }
}
