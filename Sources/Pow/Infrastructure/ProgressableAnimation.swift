//
//  ProgressableAnimation.swift
//
//
//  Created by Noah Martin on 11/30/23.
//

import Foundation
import SwiftUI

#if DEBUG
typealias DebugProgressableAnimation = ProgressableAnimation
#else
typealias DebugProgressableAnimation = Animatable
#endif

protocol ProgressableAnimation: Animatable {
  var progress: CGFloat { get set }
}

extension ProgressableAnimation where AnimatableData == CGFloat {
  var progress: CGFloat {
    get { animatableData }
    set { animatableData = newValue }
  }
}

#if DEBUG
protocol PreviewableAnimation {
  associatedtype Animation: ProgressableAnimation & ViewModifier

  static var animation: Animation { get }

  static var content: any View { get }
}

extension PreviewableAnimation {
  static var content: any View {
    RoundedRectangle(
      cornerRadius: 8,
      style: .continuous)
    .fill(Color.blue)
    .frame(width: 80, height: 80)
  }
}

extension PreviewableAnimation {
  static var previews: AnyView {
    let c = self.content
    let anyContent = AnyView(c)
    let modifiers = [0, 0.25, 0.5, 0.75, 1].map { i in
      var copy = self.animation
      copy.progress = i
      return copy
    }
    return AnyView(ForEach(Array(modifiers.enumerated()), id: \.offset) { i, modifier in
      anyContent.modifier(modifier)
        .previewDisplayName("\(String(describing: Animation.self))-\(i)")
    })
  }
}
#endif
