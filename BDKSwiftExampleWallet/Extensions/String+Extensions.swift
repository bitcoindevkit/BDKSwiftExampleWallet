//
//  String+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import Foundation

extension String {
    var formattedWithSeparator: String {
        guard let number = Int(self) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: number)) ?? self
    }

    func hexStringToByteArray() -> [UInt8] {
        var startIndex = self.startIndex
        var byteArray: [UInt8] = []

        while startIndex < self.endIndex {
            let endIndex =
                self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            let byteString = self[startIndex..<endIndex]
            if let byte = UInt8(byteString, radix: 16) {
                byteArray.append(byte)
            } else {
                return []
            }
            startIndex = endIndex
        }

        return byteArray
    }
}

#if DEBUG
    extension String {
        static var mockTransactionHex =
            "01000000000101604350f234b3b4b5fde5513ff89d222e91cabf452182ba0b8d076cf08a3813a30100000000ffffffff0240420f0000000000225120c8b7757fff5ceb41908a43bfadf749afbb97b50ece0896e88f2cd14f90844d7b8df6731d00000000225120ff38f143374565d74648006f8aabef9dad548344549d8516177ff613e26f7d360140298823f597d3cb7f4934a5ef0b1814e2ca8caa9f9da0a0b59a73922d98f83ec62587add48e3fa0d0b7cf704b2fce0277e2a70f9aed8a41f2823b810b92e0421d00000000"
    }
#endif
