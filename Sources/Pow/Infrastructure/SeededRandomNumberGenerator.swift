import Foundation

final class SeededRandomNumberGenerator : RandomNumberGenerator {
    private struct PCGRand32 {
        static let _multiplier: UInt64 = 0x5851f42d4c957f2d

        var state: UInt64     = 0x853c49e6748fea9b
        var increment: UInt64 = 0xda3e39cb94b95bdb

        mutating func seed(initializer: UInt64, sequence: UInt64) {
            state = 0
            increment = (sequence << 1) | 1
            step()
            state = state &+ initializer
            step()
        }

        mutating func step() {
            state = state &* PCGRand32._multiplier &+ increment
        }

        mutating func next() -> UInt32 {
            defer {
                step()
            }

            let shifted = UInt32(truncatingIfNeeded: ((state >> 18) ^ state) >> 27)
            let rotation = UInt32(truncatingIfNeeded: state >> 59)

            return (shifted >> rotation) | (shifted << ((~rotation &+ 1) & 31))
        }
    }

    private var a: PCGRand32

    private var b: PCGRand32

    convenience init<H: Hashable>(seed value: H) {
        self.init(seed: UInt64(truncatingIfNeeded: value.hashValue))
    }

    init(seed: UInt64) {
        a = PCGRand32()
        a.seed(initializer: seed, sequence: 666)

        b = PCGRand32()
        b.seed(initializer: seed, sequence: 123)
    }

    public func next() -> UInt64 {
        return UInt64(a.next()) << 32 | UInt64(b.next())
    }
}
