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
