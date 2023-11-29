import CoreGraphics

extension CGAffineTransform {
    init(shearX x: CGFloat, y: CGFloat) {
        self = .identity
        self.c = x
        self.b = y
    }
}

func CGAffineTransformShear(_ t: CGAffineTransform, _ x: CGFloat, _ y: CGFloat) -> CGAffineTransform {
    t.concatenating(CGAffineTransform(shearX: x, y: y))
}
