import SwiftUI

public extension View {
    /// Wraps this view in a particle layer with the given name.
    ///
    /// Particle effects such as `AnyChangeEffect.spray` can render their particles on this position in the view tree to avoid being clipped by their immediate ancestor.
    ///
    /// For example, certain `List` styles may clip their rows. Use `particleLayer(_:)` to render particles on top of the entire `List` or even its enclosing `NavigationStack`.
    func particleLayer(name: AnyHashable) -> some View {
        self
            .transformEnvironment(\.particleLayerNames) {
                $0.insert(name)
            }
            .overlayPreferenceValue(ParticleLayerPreferenceKey.self) { p in
                GeometryReader { proxy in
                    let keys: [UUID] = {
                        return p
                            .filter { $0.1.name == name }
                            .keys
                            .sorted { a, b in a.uuidString < b.uuidString }
                    }()

                    ZStack {
                        ForEach(keys, id: \.self) { key in
                            let layer = p[key]!
                            let b = proxy[layer.bounds]

                            layer.erasedContent
                                .frame(width: b.width, height: b.height)
                                .position(b.center)
                        }
                    }
                }
            }
            .transformPreference(ParticleLayerPreferenceKey.self) {
                $0 = $0.filter { $0.1.name != name }
            }
    }
}

/// A context in which particle effects draw their particles.
public struct ParticleLayer: Hashable {
    internal enum Guts: Hashable {
        case local
        case named(AnyHashable)
    }

    var guts: Guts

    var name: AnyHashable? {
        switch guts {
        case .named(let name): return name
        case .local: return nil
        }
    }

    /// A `ParticleLayer` with a given name.
    public static func named(_ name: AnyHashable) -> Self {
        Self(guts: .named(name))
    }

    /// The local particle layer.
    public static var local: Self {
        Self(guts: .local)
    }
}

internal struct ParticleLayerContents {
    var name: AnyHashable

    var content: any View

    var bounds: Anchor<CGRect>

    var erasedContent: AnyView {
        AnyView(erasing: content)
    }
}

internal struct ParticleLayerPreferenceKey: PreferenceKey {
    static var defaultValue: [UUID: ParticleLayerContents] = [:]

    static func reduce(value: inout [UUID: ParticleLayerContents], nextValue: () -> [UUID: ParticleLayerContents]) {
        value.merge(nextValue()) { _, b in b }
    }
}

internal extension EnvironmentValues {
    struct ParticleLayerNames: EnvironmentKey {
        static var defaultValue: Set<AnyHashable> = []
    }

    var particleLayerNames: Set<AnyHashable> {
        get { self[ParticleLayerNames.self] }
        set { self[ParticleLayerNames.self] = newValue }
    }
}

internal extension View {
    func particleLayerBackground(alignment: Alignment = .center, layer: ParticleLayer = .local, isEnabled: Bool = true, @ViewBuilder particle: () -> some View) -> some View {
        modifier(ParticleLayerBackgroundModifier(alignment: alignment, layer: layer, isEnabled: isEnabled, particle: particle))
    }

    func particleLayerOverlay(alignment: Alignment = .center, layer: ParticleLayer = .local, isEnabled: Bool = true, @ViewBuilder particle: () -> some View) -> some View {
        modifier(ParticleLayerOverlayModifier(alignment: alignment, layer: layer, isEnabled: isEnabled, particle: particle))
    }
}

private struct ParticleLayerBackgroundModifier<Particle: View>: ViewModifier {
    var alignment: Alignment

    var particle: Particle

    var layer: ParticleLayer

    var isEnabled: Bool

    @State
    private var layerID = UUID()

    @Environment(\.self)
    private var wholeEnvironment

    @Environment(\.particleLayerNames)
    private var particleLayerNames

    init(alignment: Alignment, layer: ParticleLayer, isEnabled: Bool, @ViewBuilder particle: () -> Particle) {
        self.alignment = alignment
        self.layer = layer
        self.isEnabled = isEnabled
        self.particle = particle()
    }

    func body(content: Content) -> some View {
        let hasParticleLayer: Bool = {
            if let name = layer.name, particleLayerNames.contains(name) {
                return true
            } else {
                return false
            }
        }()

        content
            .background(alignment: alignment) {
                if !hasParticleLayer {
                    particle
                }
            }
            .anchorPreference(key: ParticleLayerPreferenceKey.self, value: .bounds) { bounds in
                if let name = layer.name, hasParticleLayer, isEnabled {
                    return [
                        layerID: ParticleLayerContents(
                            name: name,
                            content: particle.environment(\.self, wholeEnvironment),
                            bounds: bounds
                        )
                    ]
                } else {
                    return [:]
                }
            }
    }
}

private struct ParticleLayerOverlayModifier<Particle: View>: ViewModifier {
    var alignment: Alignment

    var particle: Particle

    var layer: ParticleLayer

    var isEnabled: Bool

    @State
    private var layerID = UUID()

    @Environment(\.self)
    private var wholeEnvironment

    @Environment(\.particleLayerNames)
    private var particleLayerNames

    init(alignment: Alignment, layer: ParticleLayer, isEnabled: Bool, @ViewBuilder particle: () -> Particle) {
        self.alignment = alignment
        self.layer = layer
        self.isEnabled = isEnabled
        self.particle = particle()
    }

    func body(content: Content) -> some View {
        let hasParticleLayer: Bool = {
            if let name = layer.name, particleLayerNames.contains(name) {
                return true
            } else {
                return false
            }
        }()

        content
            .overlay(alignment: alignment) {
                if !hasParticleLayer {
                    particle
                }
            }
            .anchorPreference(key: ParticleLayerPreferenceKey.self, value: .bounds) { bounds in
                if let name = layer.name, hasParticleLayer, isEnabled {
                    return [
                        layerID: ParticleLayerContents(
                            name: name,
                            content: particle.environment(\.self, wholeEnvironment),
                            bounds: bounds
                        )
                    ]
                } else {
                    return [:]
                }
            }
    }
}
