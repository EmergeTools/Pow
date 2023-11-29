import Foundation
import CoreGraphics

internal func rubberClamp(_ min: CGFloat, _ value: CGFloat, _ max: CGFloat, coefficient: CGFloat = 0.55) -> CGFloat {
    let clamped = clamp(min, value, max)

    let delta = abs(clamped - value)

    guard delta != 0 else {
        return value
    }

    let sign: CGFloat = clamped > value ? -1 : 1

    let range = (max - min)

    return clamped + sign * (1.0 - (1.0 / ((delta * coefficient / range) + 1.0))) * range
}

internal func clamp<C: Comparable>(_ min: C, _ value: C, _ max: C) -> C {
    Swift.max(min, Swift.min(value, max))
}

internal func clamp<F: FloatingPoint>(_ value: F) -> F {
    clamp(0, value, 1)
}

internal func map<T: FloatingPoint>(value: T, inMin: T, inMax: T, outMin: T, outMax: T) -> T {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
}

internal func lerp<T: FloatingPoint>(_ value: T, outMin: T, outMax: T) -> T {
    return map(value: value, inMin: 0, inMax: 1, outMin: outMin, outMax: outMax)
}

internal func easeOut(_ t: CGFloat) -> CGFloat {
    pow(t - 1, 3) + 1
}

internal func easeInCubic(_ t: CGFloat) -> CGFloat {
    t * t * t
}

internal func easeInOutCubic(_ t: CGFloat) -> CGFloat {
    if t < 0.5 {
        return 4 * pow(t, 3)
    } else {
        return (t - 1) * pow(2 * t - 2, 2) + 1
    }
}

internal func easeInOutQuart(_ t: CGFloat) -> CGFloat {
    if t < 0.5 {
        return 8 * pow(t, 4)
    } else {
        return -1 / 2 * pow(2 * t - 2, 4) + 1
    }
}

func cubicBezier(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> (CGFloat) -> CGFloat {
    func A(_ a1: CGFloat, _ a2: CGFloat) -> CGFloat {
        1.0 - 3.0 * a2 + 3.0 * a1
    }

    func B(_ a1: CGFloat, _ a2: CGFloat) -> CGFloat {
        3.0 * a2 - 6.0 * a1
    }

    func C(_ a1: CGFloat) -> CGFloat {
        3.0 * a1
    }

    func cubicBezierCalculate(_ t: CGFloat, _ a1: CGFloat, _ a2: CGFloat) -> CGFloat {
        ((A(a1, a2) * t + B(a1, a2)) * t + C(a1)) * t
    }

    func cubicBezierSlope(_ t: CGFloat, _ a1: CGFloat, _ a2: CGFloat) -> CGFloat {
        3 * A(a1, a2) * t * t + 2 * B(a1, a2) * t + C(a1)
    }

    func binarySubdivide(_ x: CGFloat, _ x1: CGFloat, _ x2: CGFloat) -> CGFloat {
        let epsilon = 0.0000001
        let maxIterations = 10

        var start: CGFloat = 0
        var end: CGFloat = 1

        var currentX: CGFloat = 0
        var currentT: CGFloat = 0

        var i = 0

        while true {
            currentT = start + (end - start) / 2;
            currentX = cubicBezierCalculate(currentT, x1, x2) - x;

            if (currentX > 0) {
                end = currentT;
            } else {
                start = currentT;
            }

            i += 1

            if (fabs(currentX) > epsilon && i < maxIterations) {

            } else {
                break
            }
        }

        return currentT;
    }

    if (x1 == y1 && x2 == y2) {
        return { $0 }
    }

    return { x in
        let t = binarySubdivide(x, x1, x2)

        return cubicBezierCalculate(t, y1, y2)
    }
}
