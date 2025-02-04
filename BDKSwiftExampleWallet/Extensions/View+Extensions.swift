//
//  View+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 2/3/25.
//

import Foundation
import SwiftUI

extension View {
    func swipeGesture(perform action: @escaping (SwipeDirection) -> Void) -> some View {
        gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height

                    if abs(horizontal) > abs(vertical) {
                        if horizontal > 0 {
                            action(.right)
                        } else {
                            action(.left)
                        }
                    }
                }
        )
    }
}

enum SwipeDirection {
    case left, right
}
