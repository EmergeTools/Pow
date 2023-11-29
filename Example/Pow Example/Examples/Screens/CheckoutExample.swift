import Pow
import SwiftUI

struct CheckoutExample: View, Example {
    enum PaymentError: Error {
        case unknown
    }

    @State
    var result: Result<Void, Error>?

    @State
    var quantity = 1

    var body: some View {
        List {
            if case .success = result {
                VStack(alignment: .leading) {
                    Text("Thank You For Your Order")
                        .font(.title2)
                        .bold()
                    Text("We'll notify you when your order has been sent.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .listRowSeparator(.hidden)

                Spacer()

                LabeledContent("Purchase Number", value: "P023121114")
            } else {
                VStack(alignment: .leading) {
                    Text("Checkout")
                        .font(.largeTitle)
                        .bold()
                        .accessibility(addTraits: .isHeader)
                    Text(quantity > 0 ? "1 Item" : "No Items")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .listRowSeparator(.hidden)

                Spacer()

                Section {
                    if quantity > 0 {
                        CartItem(quantity: $quantity)
                    }
                }
            }

            Spacer()

            Section {
                LabeledContent("Address", value: "jane.doe@example.com")

                LabeledContent("Payment", value: "VISA")
            }
        }
        .listStyle(.plain)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: quantity != 0)
        .toolbar {
            if quantity == 0 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Undo") {
                        quantity = 1
                    }
                }
            }
        }
        .changeEffect(.feedback(SoundEffect("whop")), value: quantity == 0, isEnabled: quantity == 0)
        .changeEffect(.feedback(SoundEffect("wip")), value: quantity != 0, isEnabled: quantity != 0)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    LabeledContent("Subtotal", value: 99 * quantity, format: .currency(code: "USD"))
                        .foregroundStyle(.secondary)
                    LabeledContent("Shipping", value: 0, format: .currency(code: "USD"))
                        .foregroundStyle(.secondary)
                    LabeledContent("Total", value: 99 * quantity, format: .currency(code: "USD"))
                        .fontWeight(.heavy)
                }

                PayButton {
                    let isFirstPayAttempt = result == nil

                    try? await Task.sleep(nanoseconds: 1_000_000_000)

                    if isFirstPayAttempt {
                        throw PaymentError.unknown
                    }
                } completion: { payResult in
                    withAnimation {
                        result = payResult
                    }
                }
                .disabled(quantity == 0)
                .changeEffect(.shine.delay(1), value: quantity != 0, isEnabled: quantity != 0)
            }
            .padding()
            .background(.bar)
        }
        .labeledContentStyle(CheckoutLabeledContentStyle())
    }

    static let localPath = LocalPath()

    static var icon: Image? {
        Image(systemName: "cart")
    }

    static let newIn0_2_0: Bool = true
}

private struct CartItem: View {
    @Binding
    var quantity: Int

    @State
    var lastQuantity: Int = 0

    var body: some View {
        HStack {
            Stepper("Quantity", value: $quantity, in: 0...99)
                .labelsHidden()
                .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                    dimensions[.leading]
                }
                .changeEffect(.feedback(SoundEffect("beep")), value: quantity, isEnabled: quantity > lastQuantity && quantity > 1)
                .changeEffect(.feedback(SoundEffect("boop")), value: quantity, isEnabled: quantity < lastQuantity && quantity > 0)
                .onChange(of: quantity) { newValue in
                    lastQuantity = quantity
                }

            Text(quantity, format: .number).monospacedDigit() + Text("×")

            LabeledContent("Pow License", value: 99, format: .currency(code: "USD"))
        }
    }
}

struct PayButton: View {
    var action: () async throws -> Void

    var completion: (Result<Void, Error>) -> Void

    enum Status {
        case initial
        case inProgress
        case succeeded
        case failed
    }

    @State
    var status: Status = .initial

    var body: some View {
        Button {
            status = .inProgress
            Task {
                do {
                    try await action()
                    status = .succeeded
                    completion(.success(()))
                } catch {
                    status = .failed
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    status = .initial
                    completion(.failure(error))
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.white)
                        .opacity(status == .inProgress ? 1 : 0)
                        .animation(.spring(), value: status == .inProgress)

                    Image(systemName: "exclamationmark.triangle")
                        .opacity(status == .failed ? 1 : 0)
                        .animation(.spring(), value: status == .failed)

                    Checkmark()
                        .trim(from: 0, to: status == .succeeded ? 1 : 0)
                        .stroke(style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .padding(4)
                        .animation(.spring(response: 0.3), value: status == .succeeded)
                }
                .frame(width: 20, height: 20)
                .imageScale(.large)

                Spacer()

                switch status {
                case .initial:
                    Text("Pay")
                case .inProgress:
                    Text("Paying…")
                case .succeeded:
                    Text("Paid")
                case .failed:
                    Text("Try Again")
                }

                Color.clear
                    .frame(width: 20, height: 20)

                Spacer()
            }
        }
        .font(.headline)
        .buttonStyle(.borderedProminent)
        .transformEnvironment(\.backgroundMaterial, transform: { material in
            material = nil
        })
        .controlSize(.large)
        .animation(.spring(response: 0.3), value: status == .inProgress)
        .tint(status == .failed ? .red : status == .succeeded ? .green : nil)
        .allowsHitTesting(status == .initial)
        .changeEffect(.shake(rate: .fast), value: status == .failed, isEnabled: status == .failed)
        .changeEffect(.feedback(SoundEffect("plop")), value: status == .inProgress, isEnabled: status == .inProgress)
        .changeEffect(.feedback(SoundEffect("sparkle")), value: status == .succeeded, isEnabled: status == .succeeded)
        .changeEffect(.feedback(SoundEffect("notfound")), value: status == .failed, isEnabled: status == .failed)
    }
}

private struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        let insetFrame = rect

        let referenceSize = CGSize(width: 67, height: 68)
        let referencePoint1: CGPoint
        let referencePoint2: CGPoint
        let referencePoint3: CGPoint

        referencePoint1 = CGPoint(x: 3.5, y: 36.5)
        referencePoint2 = CGPoint(x: 25.5, y: 63.5)
        referencePoint3 = CGPoint(x: 63, y: 5.5)

        return Path { path in
            path.move(to: CGPoint(x: insetFrame.width * referencePoint1.x / referenceSize.width, y: insetFrame.height * referencePoint1.y / referenceSize.height))
            path.addLine(to: CGPoint(x: insetFrame.width * referencePoint2.x / referenceSize.width, y: insetFrame.width * referencePoint2.y / referenceSize.height))
            path.addLine(to: CGPoint(x: insetFrame.width * referencePoint3.x / referenceSize.width, y: insetFrame.width * referencePoint3.y / referenceSize.height))
        }
        .offsetBy(dx: insetFrame.origin.x, dy: insetFrame.origin.y)
    }
}

private struct CheckoutLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline) {
            configuration.label
                .font(.headline)
            Spacer()
            configuration.content
                .font(.body)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct CheckoutExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CheckoutExample()
                .toolbar(.visible, for: .navigationBar)
        }
    }
}
