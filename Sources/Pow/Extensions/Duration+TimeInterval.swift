import Foundation

@available(iOS 16.0, *)
@available(macOS 13.0, *)
@available(tvOS 16.0, *)
internal extension Duration {
    var timeInterval: TimeInterval {
        TimeInterval(components.seconds) + TimeInterval(components.attoseconds) / 1e18
    }
}
