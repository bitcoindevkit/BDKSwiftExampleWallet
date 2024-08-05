//
//  LocalOutputItemView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import SwiftUI

struct LocalOutputItemView: View {
    let output: LocalOutput
    let isRedacted: Bool
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        HStack(spacing: 15) {
            if isRedacted {
                Image(systemName: "circle.fill")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.gray.opacity(0.5))
            } else {
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.gray.opacity(0.25))
                    Image(systemName: "bitcoinsign")
                        .font(.callout)
                        .foregroundStyle(Color.bitcoinOrange)
                }
            }

            VStack(alignment: .leading, spacing: 5) {

                Text(output.outpoint.txid)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.title)
                    .foregroundColor(.primary)

                Text("Vout: \(output.outpoint.vout)")
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .font(.caption2)
                    .fontWidth(.condensed)

            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            .padding(.trailing, 30.0)
            .redacted(reason: isRedacted ? .placeholder : [])

            Spacer()

            Text("\(output.txout.value) sats")
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
                .redacted(reason: isRedacted ? .placeholder : [])

        }
        .padding(.vertical, 15.0)
        .padding(.vertical, 5.0)
        .minimumScaleFactor(0.5)
    }
}

#Preview {
    LocalOutputItemView(output: .mock, isRedacted: false)
}
