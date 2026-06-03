//
//  SwipeModifier.swift
//  MovieMatch
//
//  Created by Ilya on 26.05.2026.
//

import SwiftUI

struct SwipeModifier: ViewModifier {
    @Binding var offset: CGSize
    var onSwipeRight: () -> Void
    var onSwipeLeft: () -> Void
    var onSwipeUp: () -> Void
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset.width, y: offset.height * 0.4)
            .rotationEffect(.degrees(Double(offset.width / 15)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        if offset.width > 150 {
                            offset = CGSize(width: 500, height: 0)
                            onSwipeRight()
                        } else if offset.width < -150 {
                            offset = CGSize(width: -500, height: 0)
                            onSwipeLeft()
                        } else if offset.height < -150 {
                            offset = CGSize(width: 0, height: -800)
                            onSwipeUp()
                        } else {
                            offset = .zero
                        }
                    }
                )
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: offset)
    }
}

extension View {
    func SwipeFunction(
        offset: Binding<CGSize>,
        onSwipeRight: @escaping () -> Void,
        onSwipeLeft: @escaping () -> Void,
        onSwipeUp: @escaping () -> Void 
    ) -> some View {
        self.modifier(SwipeModifier(offset: offset, onSwipeRight: onSwipeRight, onSwipeLeft: onSwipeLeft, onSwipeUp: onSwipeUp))
    }
}
