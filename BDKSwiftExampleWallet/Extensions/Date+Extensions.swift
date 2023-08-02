//
//  Date+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/23.
//

import Foundation

extension Date {
    func formattedSyncTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        let formattedTime = formatter.string(from: self)

        return formattedTime
    }
}
