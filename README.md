![](./images/og-image.png)

# Pow

Delightful SwiftUI transitions for your app.

> **Note**
> Pow is free to test and evaluate. To deploy an app using it to the App Store, you need to [purchase a license](https://movingparts.io/pow).

# Installation

To add a package dependency to your Xcode project, select _File_ > _Add Package_ and enter this repository's URL (https://github.com/movingparts-io/Pow).

# Known issues

- [Xcode Previews depending on Pow are broken in Xcode 14b5](https://developer.apple.com/forums/thread/707569).  
  **Suggested Solution:** Download, unpack and embed the [`.xcframework` referenced in the `Package.swift`](./Package.swift) file.

# Overview

All transitions are namespaced under the `movingParts` static variable, e.g.

```swift
myView.transition(.movingParts.anvil)
```

## Anvil

[Preview](https://movingparts.io/pow/#anvil)

A transition that drops the view down from the top.

The transition is only performed on insertion and takes 1.4 seconds.

```swift
static var anvil: AnyTransition
```

## Blinds

[Preview](https://movingparts.io/pow/#blinds)

A transition that reveals the view as if it was behind window blinds.

```swift
static var blinds: AnyTransition
```

A transition that reveals the view as if it was behind window blinds.

Parameters:
- `slatWidth`: The width of each slat.
- `style`: The style of blinds, either `.venetian` or `.vertical`.
- `isStaggered`: Whether all slats opens at the same time or in sequence.

```swift
static func blinds(slatWidth: CGFloat, style: BlindsStyle = .venetian, isStaggered: Bool = false) -> AnyTransition
```

## Blur

[Preview ](https://movingparts.io/pow/#blur)

A transition from blurry to sharp on insertion, and from sharp to blurry
on removal.

```swift
static var blur: AnyTransition
```

## Boing

[Preview](https://movingparts.io/pow/#boing)

A transition that moves the view down with any overshoot resulting in an
elastic deformation of the view.

```swift
static var boing: AnyTransition
```

A transition that moves the view away towards the specified edge, with
any overshoot resulting in an elastic deformation of the view.

```swift
static func boing(edge: Edge) -> AnyTransition
```

## Clock

[Preview](https://movingparts.io/pow/#clock)

A transition using a clockwise sweep around the centerpoint of the view.

```swift
static var clock: AnyTransition
```

A transition using a clockwise sweep around the centerpoint of the view.

- Parameter `blurRadius`: The radius of the blur applied to the mask.

```swift
static func clock(blurRadius: CGFloat)  -> AnyTransition
```

## Flicker

[Preview](https://movingparts.io/pow/#flicker)

A transition that toggles the visibility of the view multiple times
before settling.

```swift
static var flicker: AnyTransition
```

A transition that toggles the visibility of the view multiple times
before settling.

- Parameter `count`: The number of times the visibility is toggled.

```swift
static func flicker(count: Int) -> AnyTransition
```

## Film Exposure

[Preview](https://movingparts.io/pow/#film-exposure)

A transition from completely dark to fully visible on insertion, and
from fully visible to completely dark on removal.

```swift
static var filmExposure: AnyTransition
```

## Flip

[Preview](https://movingparts.io/pow/#flip)

A transition that inserts by rotating the view towards the viewer, and
removes by rotating the view away from the viewer.

> **Note:**
> Any overshoot of the animation will result in the view continuing the rotation past the view's normal state before eventually settling.

```swift
static var flip: AnyTransition
```

## Glare

[Preview](https://movingparts.io/pow/#glare)

A transitions that shows the view by combining a diagonal wipe with a
white streak.

```swift
static var glare: AnyTransition
```

A transitions that shows the view by combining a wipe with a colored
streak.

The angle is relative to the current `layoutDirection`, such that 0°
represents sweeping towards the leading edge on insertion and 90°
represents sweeping towards the top edge.

In this example, the removal of the view is using a glare with an
exponential ease-in curve, combined with a anticipating scale animation,
making for a more dramatic exit.

```swift
infoBox
  .transition(
    .asymmetric(
      insertion: .movingParts.glare(angle: .degrees(225)),
      removal: .movingParts.glare(angle: .degrees(45)
    )
    .animation(.movingParts.easeInExponential(duration: 0.9))
        .combined(with:
          .scale(scale: 1.4)
            .animation(.movingParts.anticipate(duration: 0.9).delay(0.1)
        )
      )
    )
  )
```

- Parameters:
  - `direction`: The angle of the wipe.
  - `color`: The color of the glare effect.

```swift
static func glare(angle: Angle, color: Color = .white) -> AnyTransition
```

## Iris

[Preview](https://movingparts.io/pow/#iris)

A transition that takes the shape of a growing circle when inserting,
and a shrinking circle when removing.

- Parameters:
  - `origin`: The center point of the circle as it grows or shrinks.
  - `blurRadius`: The radius of the blur applied to the mask.

```swift
static func iris(origin: UnitPoint = .center, blurRadius: CGFloat = 0) -> AnyTransition
```

## Move

[Preview](https://movingparts.io/pow/#move)

A transition that moves the view from the specified edge of the on
insertion and towards it on removal.

```swift
static func move(edge: Edge) -> AnyTransition
```

A transition that moves the view at the specified angle.

The angle is relative to the current `layoutDirection`, such that 0° represents animating towards the leading edge on insertion and 90° represents inserting towards the top edge.

In this example, the view insertion is animated by moving it towards the top trailing corner and the removal is animated by moving it towards the bottom edge.

```swift
Text("Hello")
  .transition(
    .asymmetric(
      insertion: .movingParts.move(angle: .degrees(45)),
      removal:   .movingParts.move(angle: .degrees(90))
    )
  )
```

- Parameter `angle`: The direction of the animation.

```swift
static func move(angle: Angle) -> AnyTransition
```

## Pop

[Preview](https://movingparts.io/pow/#pop)

A transition that shows a view with a ripple effect and a flurry of
tint-colored particles.

The transition is only performed on insertion and takes 1.2 seconds.

```swift
static var pop: AnyTransition
```

A transition that shows a view with a ripple effect and a flurry of
colored particles.

In this example, the star uses the pop effect only when transitioning
from `starred == false` to `starred == true`:

```swift
Button {
  starred.toggle()
} label: {
  if starred {
    Image(systemName: "star.fill")
      .foregroundStyle(.orange)
      .transition(.movingParts.pop(.orange))
  } else {
    Image(systemName: "star")
      .foregroundStyle(.gray)
      .transition(.identity)
  }
}
```

The transition is only performed on insertion.

- Parameter `style`: The style to use for the effect.

```swift
static func pop<S: ShapeStyle>(_ style: S) -> AnyTransition
```

## Poof

[Preview](https://movingparts.io/pow/#poof)

A transition that removes the view in a dissolving cartoon style cloud.

The transition is only performed on removal and takes 0.4 seconds.

```swift
static var poof: AnyTransition
```

## Rotate3D

A transition that inserts by rotating from the specified rotation, and
removes by rotating to the specified rotation in three dimensions.

In this example, the view is rotated 90˚ about the y axis around
its bottom edge as if it was rising from lying on its back face:

```swift
Text("Hello")
  .transition(.movingParts.rotate3D(
    .degrees(90),
      axis: (1, 0, 0),
      anchor: .bottom,
      perspective: 1.0 / 6.0)
  )
```

> **Note:**
> Any overshoot of the animation will result in the view continuing the rotation past the view's normal state before eventually settling.

- Parameters:
  - `angle`: The angle from which to rotate the view.
  - `axis`: The x, y and z elements that specify the axis of rotation.
  - `anchor`: The location with a default of center that defines a point
            in 3D space about which the rotation is anchored.
  - `anchorZ`: The location with a default of 0 that defines a point in 3D
             space about which the rotation is anchored.
  - `perspective`: The relative vanishing point with a default of 1 for
                 this rotation.

```swift
static func rotate3D(_ angle: Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint = .center, anchorZ: CGFloat = 0, perspective: CGFloat = 1) -> AnyTransition
```

## Snapshot

[Preview](https://movingparts.io/pow/#film-exposure)

A transition from completely bright to fully visible on insertion, and
from fully visible to completely bright on removal.

```swift
static var filmExposure: AnyTransition
```

## Skid

[Preview](https://movingparts.io/pow/#skid)

A transition that moves the view in from its leading edge with any
overshoot resulting in an elastic deformation of the view.

```swift
static var skid: AnyTransition
```

A transition that moves the view in from the specified edge during
insertion and towards it during removal with any overshoot resulting
in an elastic deformation of the view.

- Parameter `direction`: The direction of the transition.

```swift
static func skid(direction: SkidDirection) -> AnyTransition
```

## Swoosh

[Preview](https://movingparts.io/pow/#swoosh)

A three-dimensional transition from the back of the towards the front
during insertion and from the front towards the back during removal.

```swift
static var swoosh: AnyTransition
```

## Vanish

[Preview](https://movingparts.io/pow/#vanish)

A transition that dissolves the view into many small particles.

The transition is only performed on removal.

> **Note:**
> This transition will use an ease-out animation with a duration of 900ms by default.

```swift
static var vanish: AnyTransition
```

A transition that dissolves the view into many small particles.

The transition is only performed on removal.

> **Note:**
> This transition will use an ease-out animation with a duration of 900ms by default.

- Parameter `style`: The style to use for the particles.

```swift
static func vanish<S: ShapeStyle>(_ style: S) -> AnyTransition
```

## Wipe

[Preview](https://movingparts.io/pow/#wipe)

A transition using a sweep from the specified edge on insertion, and
towards it on removal.

- Parameters:
  - `edge`: The edge at which the sweep starts or ends.
  - `blurRadius`: The radius of the blur applied to the mask.

```swift
static func wipe(edge: Edge, blurRadius: CGFloat = 0) -> AnyTransition
```
