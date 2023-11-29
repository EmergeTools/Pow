import SwiftUI

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )

        self.init(origin: origin, size: size)
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    var diagonal: CGFloat {
        sqrt(width * width + height * height)
    }

    func boundingBox(at angle: Angle) -> CGRect {
        CGRect(center: center, size: size.boundingSize(at: angle))
    }

    var topLeft: CGPoint {
        CGPoint(x: minX, y: minY)
    }

    var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }

    var bottomRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }

    var bottomLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }
}
