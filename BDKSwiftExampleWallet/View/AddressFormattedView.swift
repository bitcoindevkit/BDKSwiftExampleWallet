//
//  AddressFormattedView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/21/24.
//

import SwiftUI

// Can add a bunch of different options for variables in the future
struct AddressFormattedView: View {
    let address: String
    let columns: Int
    let spacing: CGFloat
    let gridItemSize: CGFloat

    init(
        address: String,
        columns: Int = 3,
        spacing: CGFloat = 10,
        gridItemSize: CGFloat = 80
    ) {
        self.address = address
        self.columns = columns
        self.spacing = spacing
        self.gridItemSize = gridItemSize
    }

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(
                    .fixed(gridItemSize),
                    spacing: spacing
                ),
                count: columns
            ),
            spacing: spacing
        ) {
            let chunks = chunkedAddress()
            ForEach(chunks.indices, id: \.self) { index in
                Text(chunks[index])
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(index % 2 == 0 ? .primary : .secondary)
            }
        }
    }
}

extension AddressFormattedView {
    func chunkedAddress() -> [String] {
        let chunkSize = 4
        return stride(from: 0, to: address.count, by: chunkSize).map {
            let start = address.index(address.startIndex, offsetBy: $0)
            let end =
                address.index(start, offsetBy: chunkSize, limitedBy: address.endIndex)
                ?? address.endIndex
            return String(address[start..<end])
        }
    }
}

#Preview {
    AddressFormattedView(address: "tb1pw6y0vtmsn46epvz0j8ddc46ketmp28t82p22hcrrkch3a0jhu40qe267dl")
}
