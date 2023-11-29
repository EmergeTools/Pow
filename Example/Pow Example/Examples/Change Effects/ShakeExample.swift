import Pow
import SwiftUI

struct ShakeExample: View, Example {
    @State var password = ""

    @State var loginAttempts = 0

    @State var isProcessing = false

    var body: some View {
        ZStack {
            GroupBox("Sign In") {
                VStack(alignment: .leading, spacing: 12) {
                    SecureField("Password", text: $password)
                        .changeEffect(.shake(rate: .fast), value: loginAttempts)
                        .onSubmit {
                            Task {
                                isProcessing = true
                                defer { isProcessing = false }

                                try? await Task.sleep(for: .seconds(1))

                                loginAttempts += 1
                            }
                        }
                        .disabled(isProcessing)
                        .textFieldStyle(.roundedBorder)
                        .changeEffect(.shake(rate: .fast), value: loginAttempts)

                    Text("Submit the form to see the effect.").font(.caption).foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: 320)
            .padding(24)
        }
        .defaultBackground()
    }

    static var description: some View {
        Text("""
        An effect that shakes the view when a change happens.

        - `rate`: The rate of the shake.
        """)
    }

    static let localPath = LocalPath()
    
    static var icon: Image? {
        Image(systemName: "arrow.left.arrow.right")
    }
}
