import SwiftUI

extension CGSize {
    var area: CGFloat {
        width * height
    }

    func boundingSize(at angle: Angle) -> CGSize {
        var theta: Double = angle.radians

        let sizeA: CGSize = CGSize(
            width:  abs(width * cos(Double(theta)) + height * sin(Double(theta))),
            height: abs(width * sin(Double(theta)) + height * cos(Double(theta)))
        )

        theta += .pi / 2

        let sizeB: CGSize = CGSize(
            width: abs(width * sin(Double(theta)) + height * cos(Double(theta))),
            height:  abs(width * cos(Double(theta)) + height * sin(Double(theta)))
        )

        if sizeA.area > sizeB.area {
            return sizeA
        } else {
            return sizeB
        }
    }
}
