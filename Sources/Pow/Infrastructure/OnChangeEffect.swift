import Foundation
import SwiftUI
import Dispatch

public extension View {
    /// Applies the given change effect to this view when the specified value changes.
    ///
    /// - Parameters:
    ///   - effect: The effect to apply.
    ///   - value: A value to monitor for changes.
    ///   - isEnabled: A Boolean value that indicates whether the effect should be applied when the value changes.  Defaults to `true`.
    ///
    /// - Returns: A view that applies the effect to this view whenever value changes.
    @ViewBuilder
    func changeEffect<V: Equatable>(_ effect: AnyChangeEffect, value: V, isEnabled: @autoclosure @escaping () -> Bool = true) -> some View {
        modifier(HighlightChangeModifier(value, effect: effect, predicate: { _ in isEnabled() }))
    }
}

struct HighlightChangeModifier<Value: Equatable>: ViewModifier {
    var value: Value

    var effect: AnyChangeEffect

    var predicate: (Value) -> Bool

    @State
    private var changeCount: Int = 0

    @State
    private var lastUpdate: Date = .distantPast

    init(_ value: Value, effect: AnyChangeEffect, predicate: @escaping (Value) -> Bool) {
        self.value = value
        self.effect = effect
        self.predicate = predicate
    }

    func body(content: Content) -> some View {
        let t = effect.viewModifier(changeCount: changeCount)
        let cooldown = effect.cooldown
        let delay = effect.delay

        func update(_ newValue: Value) {
            guard predicate(newValue), value != newValue else { return }

            guard lastUpdate.timeIntervalSinceNow < -cooldown else { return }
            lastUpdate = .now

            changeCount += 1
        }

        return content
            .onChange(of: value) { newValue in
                if delay == 0 {
                    update(newValue)
                } else {
                    let when = DispatchQueue.SchedulerTimeType(DispatchTime.now() + delay)

                    DispatchQueue.main.schedule(after: when, tolerance: 0.016) {
                        update(newValue)
                    }
                }
            }
            .modifier(t)
    }
}

#if os(iOS) && DEBUG
struct OnChangeEffectPreview_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var value: Int = 0

        @State
        var delay: Double = 0

        var body: some View {
            VStack(spacing: 8) {
                GroupBox {
                    Stepper(value: $value) {
                        Text("Value ") + Text("(\(value.formatted()))").foregroundColor(.secondary)
                    }

                    Stepper(value: $value.animation(.easeInOut)) {
                        Text("Value (animated) ") + Text("(\(value.formatted()))").foregroundColor(.secondary)
                    }

                    Slider(value: $delay, in: -2 ... 2)
                }

                VStack(spacing: 32) {
                    Label("Shine (Default)", systemImage: "arrow.forward.square")
                        .foregroundColor(.white)
                        .padding()
                        .background(.blue)
                        .changeEffect(.shine.delay(delay), value: value)

                    Label("Ping", systemImage: "arrow.forward.square")
                        .foregroundColor(.white)
                        .padding()
                        .background(.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .changeEffect(.pulse(shape: RoundedRectangle(cornerRadius: 16, style: .continuous), count: 3), value: value)
                        .tint(.green)

                    Label("Jump", systemImage: "arrow.forward.square")
                        .foregroundColor(.white)
                        .padding()
                        .background(.orange, in: Capsule(style: .continuous))
                        .changeEffect(.jump(height: 50), value: value)

                    Label("Spin Simulation", systemImage: "arrow.forward.square")
                        .foregroundColor(.white)
                        .padding()
                        .background(.red, in: Capsule(style: .continuous))
                        .changeEffect(.spin, value: value)

                    HStack {
                        let effect = AnyChangeEffect.spray {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.system(size: 40))
                        }

                        Label("Spray", systemImage: "sparkles")
                            .foregroundColor(.white)
                            .padding()
                            .background(.blue, in: Capsule(style: .continuous))

                            .changeEffect(effect, value: value)

                        Label("Spray (delay)", systemImage: "sparkles")
                            .foregroundColor(.white)
                            .padding()
                            .background(.blue, in: Capsule(style: .continuous))
                            .changeEffect(effect.delay(0.5), value: value)
                    }

                    Label("Shake", systemImage: "arrow.left.arrow.right")
                        .foregroundColor(.white)
                        .padding()
                        .background(.purple, in: Capsule(style: .continuous))
                        .changeEffect(.shake, value: value)
                }
            }
            .padding()
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
