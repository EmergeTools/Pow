import SwiftUI

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))
    }

    func angle(to other: CGPoint) -> Angle {
        Angle(radians: atan2(other.y - y, other.x - x))
    }
}
