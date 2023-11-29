import Pow
import SwiftUI

struct ShineExample: View, Example {
    @State var name = ""


    var body: some View {
        ZStack {
            GroupBox("Sign In") {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 24)

                Button {

                } label: {
                    Spacer()
                    Text("Submit")
                    Spacer()
                }
                .disabled(name.isEmpty)
                .changeEffect(.shine.delay(1), value: name.isEmpty, isEnabled: !name.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 320)
            .padding(24)
        }
        .defaultBackground()
        .onTapGesture {
            if name.isEmpty {
                name = "Jay Appleseed"
            }
        }
    }

    static var description: some View {
        Text("""
        Highlights the view with a shine moving over the view.

        The angle is relative to the current `layoutDirection`, such that 0° represents sweeping towards the trailing edge and 90° represents sweeping towards the top edge.

        - Parameters:
            - `angle`: The angle of the animation.
            - `duration`: The duration of the animation.
        """)
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "sparkles")
    }
}
