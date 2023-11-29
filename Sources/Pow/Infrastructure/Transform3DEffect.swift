import SwiftUI
import simd

internal struct Transform3DEffect: GeometryEffect, Animatable {
    var animatableData: AnimatablePair<TRS, AnimatablePair<Anchor3D, Double>> = .zero

    init(translation: simd_double3 = .zero, rotation: simd_quatd = simd_quatd(angle: 0, axis: .zero), scale: simd_double3 = [1, 1, 1], anchor: UnitPoint = .center, anchorZ: Double = 0, perspective: Double = 1) {
        self.animatableData.first = TRS(translation: translation, rotation: rotation, scale: scale)
        self.animatableData.second.first = Anchor3D(xy: anchor, z: anchorZ)
        self.animatableData.second.second = perspective
    }

    init(
        translation: (x: Double, y: Double, z: Double) = (0, 0, 0),
        angle: Angle = .zero,
        axis: (x: Double, y: Double, z: Double) = (0, 0, 0),
        scale: (x: Double, y: Double, z: Double) = (1, 1, 1),
        anchor: UnitPoint = .center,
        anchorZ: Double = 0.0,
        perspective: Double = 1
    ) {
        self.animatableData.first = TRS(
            translation: [translation.x, translation.y, translation.z],
            rotation: .init(angle: angle.radians, axis: [axis.x, axis.y, axis.z]),
            scale: [scale.x, scale.y, scale.z]
        )
        self.animatableData.second.first = Anchor3D(xy: anchor, z: anchorZ)
        self.animatableData.second.second = perspective
    }

    init(animatableData: AnimatableData) {
        self.animatableData = animatableData
    }

    private var trs: TRS {
        get { animatableData.first }
        set { animatableData.first = newValue }
    }

    private var anchor: Anchor3D {
        get { animatableData.second.first }
        set { animatableData.second.first = newValue }
    }

    private var perspective: Double {
        get { animatableData.second.second }
        set { animatableData.second.second = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = simd_double4x4(translationX: size.width * anchor.xy.x, y: size.height * anchor.xy.y, z: anchor.z)

        let perspective = simd_double4x4(perspective: perspective)

        let translation = simd_double4x4(translationX: trs.translation.x, y: trs.translation.y, z: trs.translation.z)

        let rotation = simd_double4x4(trs.rotation.normalized)

        let scale = simd_double4x4(scaleX: trs.scale.x, y: trs.scale.y, z: trs.scale.z)

        return ProjectionTransform((((offset * (perspective * translation)) * rotation) * scale) * offset.inverse)
    }

    var shaded: ShadedTransform3DEffect {
        ShadedTransform3DEffect(animatableData: animatableData)
    }

    func shaded(lightSource: (x: Double, y: Double, z: Double)) -> ShadedTransform3DEffect {
        ShadedTransform3DEffect(animatableData: animatableData, lightSource: lightSource)
    }
}

extension Transform3DEffect {
    internal struct Anchor3D: Equatable {
        var xy: UnitPoint = .center

        var z: Double = 0
    }
}

extension Transform3DEffect.Anchor3D: VectorArithmetic {
    mutating func scale(by rhs: Double) {
        xy.x *= rhs
        xy.y *= rhs
        z *= rhs
    }

    var magnitudeSquared: Double {
        xy.x * xy.x + xy.y * xy.y + z * z
    }

    static var zero: Self {
        Self(xy: .zero)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        var result = Self()
        result.xy.x = lhs.xy.x + rhs.xy.x
        result.xy.y = lhs.xy.y + rhs.xy.y
        result.z = lhs.z + rhs.z

        return result
    }

    static func - (lhs: Self, rhs: Self) -> Transform3DEffect.Anchor3D {
        var result = Self()
        result.xy.x = lhs.xy.x - rhs.xy.x
        result.xy.y = lhs.xy.y - rhs.xy.y
        result.z = lhs.z - rhs.z

        return result
    }
}

internal struct ShadedTransform3DEffect: ViewModifier, Animatable {
    var animatableData: Transform3DEffect.AnimatableData

    var lightSource: (x: Double, y: Double, z: Double) = (0, -1, 0)

    fileprivate init(animatableData: AnimatableData = .zero, lightSource: (x: Double, y: Double, z: Double) = (0, -1, 0)) {
        self.animatableData = animatableData
        self.lightSource = lightSource
    }

    private var trs: TRS {
        get { animatableData.first }
        set { animatableData.first = newValue }
    }

    func body(content: Content) -> some View {
        let normal = animatableData.first.viewNormal

        let lightVector  = simd_double3(lightSource.x, lightSource.y, lightSource.z)
        let screenVector = simd_double3(0,  0, 1)

        let n: CGFloat = {
            if dot(normal, screenVector) >= 0 {
                return dot(lightVector, normal)
            } else {
                return dot(lightVector, -normal)
            }
        }()

        content
            .brightness(n * 0.2)
            .compositingGroup()
            .modifier(Transform3DEffect(animatableData: animatableData))
    }
}

#if os(iOS) && DEBUG
@available(iOS 16.0, *)
struct Transform3DEffect_Preview: PreviewProvider {
    struct Preview: View {
        @State
        var anchor: (x: Double, y: Double, z: Double) = (0.5, 0.5, 0)

        @State
        var translation: (x: Double, y: Double, z: Double) = (0, 0, 0)

        @State
        var angle: (x: Angle, y: Angle, z: Angle) = (.zero, .zero, .zero)

        @State
        var scale: (x: Double, y: Double, z: Double) = (1, 1, 1)

        @State
        var perspective: CGFloat = 0.16

        var body: some View {
            let x = simd_quatd(angle: angle.x.radians, axis: [1, 0, 0])
            let y = simd_quatd(angle: angle.y.radians, axis: [0, 1, 0])
            let z = simd_quatd(angle: angle.z.radians, axis: [0, 0, 1])

            let t = Transform3DEffect(
                translation: [translation.x, translation.y, translation.z + anchor.z],
                rotation: (x * y * z),
                scale: [scale.x, scale.y, scale.z],
                anchor: UnitPoint(x: anchor.x, y: anchor.y),
                anchorZ: anchor.z,
                perspective: perspective
            )
            .shaded

            VStack(alignment: .leading) {
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Perspective")
                        Slider(value: $perspective, in: 0 ... 1)
                    }

                    GridRow {
                        Text("anchor.x")
                        Slider(value: $anchor.x, in: 0 ... 1)
                    }

                    GridRow {
                        Text("anchor.y")
                        Slider(value: $anchor.y, in: 0 ... 1)
                    }
                    GridRow {
                        Text("anchor.z")
                        Slider(value: $anchor.z, in: -40 ... 40)
                    }


//                    GridRow {
//                        Text("translation.x")
//                        Slider(value: $translation.x, in: -150 ... 150)
//                    }
//
//                    GridRow {
//                        Text("translation.y")
//                        Slider(value: $translation.y, in: -150 ... 150)
//                    }
//                    GridRow {
//                        Text("translation.z")
//                        Slider(value: $translation.z, in: -150 ... 150)
//                    }

                    GridRow {
                        Label("Pitch", systemImage: "trapezoid.and.line.vertical")
                        Slider(value: $angle.x.degrees, in: -180 ... 180)
                    }

                    GridRow {
                        Label("Roll", systemImage: "circle.and.line.horizontal")
                        Slider(value: $angle.z.degrees, in: -180 ... 180)
                    }

                    GridRow {
                        Label("Yaw", systemImage: "trapezoid.and.line.horizontal")
                        Slider(value: $angle.y.degrees, in: -180 ... 180)
                    }
                }

                HStack {
                    Button {
                        withAnimation(.interpolatingSpring(stiffness: 30, damping: 5)) {
                            perspective = 0.16
                            anchor = (0.5, 0.5, 0)
                            translation = (0, 0, 0)
                            angle = (.zero, .zero, .zero)
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.uturn.backward")
                    }

                    Button {
                        withAnimation(.interpolatingSpring(stiffness: 30, damping: 5)) {
                            angle.x = .degrees(.random(in: -180 ... 180))
                            angle.y = .degrees(.random(in: -180 ... 180))
                            angle.z = .degrees(.random(in: -180 ... 180))
                        }
                    } label: {
                        Label("Shuffle", systemImage: "dice")
                    }
                }
                .buttonStyle(.bordered)

                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.blue.gradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(.black.opacity(0.3), lineWidth: 4)
                    }
                    .overlay {
                        HStack {
                            Spacer()
                            Color.white.frame(width: 1)
                            Spacer()
                            Color.white.frame(width: 1)
                            Spacer()
                            Color.white.frame(width: 1)
                            Spacer()
                            Color.white.frame(width: 1)
                            Spacer()
                        }
                        .opacity(0.5)
                    }
                    .overlay {
                        VStack {
                            Spacer()
                            Color.white.frame(height: 1)
                            Spacer()
                            Color.white.frame(height: 1)
                            Spacer()
                            Color.white.frame(height: 1)
                            Spacer()
                            Color.white.frame(height: 1)
                            Spacer()
                        }
                        .opacity(0.5)
                    }
                    .overlay {
                        Text("Hello\nWorld")
                            .font(.system(size: 40, design: .rounded).bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(40)
                    .compositingGroup()
                    .modifier(t)
                    .offset(y: -15)

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
