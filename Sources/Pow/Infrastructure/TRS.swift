import SwiftUI
import simd

internal struct TRS: Equatable {
    var translation: simd_double3 = .zero

    var rotation: simd_quatd = .init()

    var scale: simd_double3 = .zero

    init() {}

    init(translation: simd_double3, rotation: simd_quatd, scale: simd_double3) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }
}

extension TRS {
    static let identity = TRS(translation: [0, 0, 0], rotation: .init(), scale: [1, 1, 1])
}

extension TRS {
    var viewNormal: simd_double3 {
        let s: simd_double4 = [0, 0, 1, 0]

        let translation = simd_double4x4(translationX: translation.x, y: translation.y, z: translation.z)

        let rotation = simd_double4x4(rotation.normalized)

        let scale = simd_double4x4(scaleX: scale.x, y: scale.y, z: scale.z)

        let r = ((translation * rotation) * scale) * s

        return [r.x, r.y, r.z]
    }
}

extension TRS: VectorArithmetic {
    mutating func scale(by rhs: Double) {
        translation *= rhs
        rotation *= rhs

        scale *= rhs
    }

    var magnitudeSquared: Double {
        (translation * translation).sum() +
        rotation.real * rotation.real +
        (rotation.imag * rotation.imag).sum() +
        (scale * scale).sum()
    }

    static var zero: Self {
        Self()
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        var result = Self()
        result.translation = lhs.translation + rhs.translation
        result.rotation = lhs.rotation + rhs.rotation
        result.scale = lhs.scale + rhs.scale

        return result
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        var result = Self()
        result.translation = lhs.translation - rhs.translation
        result.rotation = lhs.rotation - rhs.rotation
        result.scale = lhs.scale - rhs.scale

        return result
    }
}
