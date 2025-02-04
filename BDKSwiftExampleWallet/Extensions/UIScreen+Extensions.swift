//
//  UIScreen+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 12/23/24.
//

import Foundation
import UIKit

extension UIScreen {
    static let iPhoneSEHeight: CGFloat = 667

    var isPhoneSE: Bool {
        self.bounds.height <= UIScreen.iPhoneSEHeight
    }
}
