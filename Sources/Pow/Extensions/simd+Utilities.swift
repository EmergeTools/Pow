import simd

internal extension simd_double4x4 {
    init(translationX x: Double, y: Double, z: Double = 0) {
        self.init(diagonal: [1, 1, 1, 1])

        self[3][0] = x
        self[3][1] = y
        self[3][2] = z
    }

    init(scaleX x: Double, y: Double, z: Double = 0) {
        self.init(diagonal: [x, y, z, 1])
    }

    init(perspective: Double) {
        self.init(diagonal: [1, 1, 1, 1])
        self[2][3] = -perspective / 100
    }
}
