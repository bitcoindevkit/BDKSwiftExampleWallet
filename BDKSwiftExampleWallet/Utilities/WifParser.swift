//
//  WifParser.swift
//  BDKSwiftExampleWallet
//
//  Created by otaliptus on 3/3/26.
//

import Foundation

// Note: this parser is just a pretty simple heuristic for the simple wallet
enum WifParser {
    static func extract(from value: String) -> String? {
        var candidates = [value]

        if let components = URLComponents(string: value),
            let queryItems = components.queryItems
        {
            for item in queryItems {
                let key = item.name.lowercased()
                if key == "wif" || key == "privkey" || key == "private_key" || key == "privatekey",
                    let itemValue = item.value
                {
                    candidates.append(itemValue)
                }
            }
        }

        for candidate in candidates {
            var token = candidate.trimmingCharacters(in: .whitespacesAndNewlines)

            if token.lowercased().hasPrefix("wif:") {
                token = String(token.dropFirst(4))
            }

            if isLikelyWif(token) {
                return token
            }
        }

        return nil
    }

    static func isLikelyWif(_ value: String) -> Bool {
        guard value.count == 51 || value.count == 52 else {
            return false
        }

        guard let first = value.first, "5KL9c".contains(first) else {
            return false
        }

        let base58Charset = CharacterSet(
            charactersIn: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        )
        return value.unicodeScalars.allSatisfy { base58Charset.contains($0) }
    }
}
