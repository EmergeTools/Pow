import SwiftUI

#if os(iOS) || os(tvOS)
protocol ViewRepresentable: UIViewRepresentable {
    associatedtype ViewType = UIViewType
    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
}

extension ViewRepresentable {
    func makeUIView(context: Context) -> ViewType {
        makeView(context: context)
    }

    func updateUIView(_ uiView: ViewType, context: Context) {
        updateView(uiView, context: context)
    }
}
#elseif os(macOS)
protocol ViewRepresentable: NSViewRepresentable {
    associatedtype ViewType = NSViewType
    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
}

extension ViewRepresentable {
    func makeNSView(context: Context) -> ViewType {
        makeView(context: context)
    }

    func updateNSView(_ nsView: ViewType, context: Context) {
        updateView(nsView, context: context)
    }
}
#endif
