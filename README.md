![](./previews/og-image.png)

# Pow

Delightful SwiftUI transitions for your app.

> **Note**
> This is a Beta version.
>
> Pow is free while in Beta and will be a simple one-time purchase after that.

# Installation

To add a package dependency to your Xcode project, select _File_ > _Add Package_ and enter this repository's URL (https://github.com/movingparts-io/Pow).

# Known issues

- [Xcode Previews depending on Pow are broken in Xcode 14b5](https://developer.apple.com/forums/thread/707569).  
  **Suggested Solution:** Download, unpack and embed the [`.xcframework` referenced in the `Package.swift`](./Package.swift) file.
- Preview videos in the README don't render in Chrome, Firefox https://github.com/movingparts-io/Pow/issues/1.
  **Suggested Solution:** Open this page in Safari.

# Overview

All transitions are namespaced under the `movingParts` static variable, e.g.

```swift
myView.transition(.movingParts.anvil)
```

## Anvil

<!--![A view dropping down like an avil, hitting the ground in a cloud of dust.](./previews/anvil.mov)-->
https://user-images.githubusercontent.com/69565038/185209401-97735306-ed34-496d-911c-643df0ea2dea.mov

A transition that drops the view down from the top.

The transition is only performed on insertion and takes 1.4 seconds.

```swift
static var anvil: AnyTransition
```

## Blur 

A transition from blurry to sharp on insertion, and from sharp to blurry
on removal.

```swift
static var blur: AnyTransition
```

## Boing

<!--![A view dropping down, deforming as it hits its resing position as if made from jelly.](./previews/boing.mov)-->
https://user-images.githubusercontent.com/69565038/185209566-abf21b51-9a9e-4bb9-91c5-e0fb5c0936a3.mov

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

## Flip

<!--![A view rotating into view.](./previews/flip.mov)-->
https://user-images.githubusercontent.com/69565038/185209630-d78bcaaa-f739-419f-a57b-815c77c7233a.mov

A transition that inserts by rotating the view towards the viewer, and
removes by rotating the view away from the viewer.

> **Note:**
> Any overshoot of the animation will result in the view continuing the rotation past the view's normal state before eventually settling.

```swift
static var flip: AnyTransition
```

## Glare

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

<!--![A view that appears with a white steak and disappears with the same streak, combined with a rising up animation.](./previews/glare.mov)-->
https://user-images.githubusercontent.com/69565038/185209680-11184d6a-907f-4933-83a1-4f85a947e1ac.mov

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

A transition that takes the shape of a growing circle when inserting,
and a shrinking circle when removing.

- Parameters:
  - `origin`: The center point of the circle as it grows or shrinks.
  - `blurRadius`: The radius of the blur applied to the mask.

```swift
static func iris(origin: UnitPoint = .center, blurRadius: CGFloat = 0) -> AnyTransition
```

## Move

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

<!--![A view that appears following a ripple effect and colored particles.](./previews/pop.mov)-->
https://user-images.githubusercontent.com/69565038/185209730-0a270355-5bd7-4b14-bf38-cbb731162e90.mov

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
static func pop(_ style: AnyShapeStyle) -> AnyTransition
```

## Rotate3D

A transition that inserts by rotating from the specified rotation, and
removes by rotating to the specified rotation in three dimensions.

In this example, the view is rotated 90˚ about the y axis around
its bottom edge as if it was rising from lying on its back face:

<!--![A view that raises up from lying on its back, overshooting as it does.](./previews/rotate3d.mov)-->
https://user-images.githubusercontent.com/69565038/185209777-0feeea04-488e-41af-9f89-7dd019fd065e.mov

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

## Skid

<!--![A sliding in from the left, overshowing and deforming as it moves.](./previews/skid.mov)-->
https://user-images.githubusercontent.com/69565038/185209827-5239a75e-f1eb-406b-8250-58851c358863.mov

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

A three-dimensional transition from the back of the towards the front
during insertion and from the front towards the back during removal.

```swift
static var swoosh: AnyTransition
```

## Vanish

<!--![A view that dissolves into many small particles.](./previews/vanish.mov)-->
https://user-images.githubusercontent.com/69565038/185209880-25d91221-e433-4e77-be53-39c3b8883d44.mov

A transition that dissolves the view into many small particles.

The transition is only performed on removal.

```swift
static var vanish: AnyTransition
```

## Wipe

A transition using a sweep from the specified edge on insertion, and
towards it on removal.

- Parameters:
  - `edge`: The edge at which the sweep starts or ends.
  - `blurRadius`: The radius of the blur applied to the mask.

```swift
static func wipe(edge: Edge, blurRadius: CGFloat = 0) -> AnyTransition
```
