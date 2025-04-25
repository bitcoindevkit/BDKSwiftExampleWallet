//
//  BalanceView.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 22/04/25.
//

import SwiftUI

struct BalanceView: View {

    @State private var balanceTextPulsingOpacity: Double = 0.7

    private var format: BalanceDisplayFormat
    private let balance: UInt64
    private var fiatPrice: Double
    private var satsPrice: Double {
        let usdValue = Double(balance).valueInUSD(price: fiatPrice)
        return usdValue
    }

    private var currencySymbol: some View {
        Image(systemName: format == .fiat ? "dollarsign" : "bitcoinsign")
            .foregroundStyle(.secondary)
            .font(.title)
            .fontWeight(.thin)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                )
            )
            .opacity(format == .sats || format == .bip21q ? 0 : 1)
            .id("symbol-\(format)")
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: format)
    }

    @MainActor
    private var formattedBalance: String {
        switch format {
        case .sats:
            return balance.formatted(.number)
        case .bitcoin:
            return String(format: "%.8f", Double(balance) / 100_000_000)
        case .bitcoinSats:
            return balance.formattedSatoshis()
        case .bip21q:
            return balance.formatted(.number)
        case .fiat:
            return satsPrice.formatted(.number.precision(.fractionLength(2)))
        }
    }

    @MainActor
    var balanceText: some View {
        Text(format == .fiat && satsPrice == 0 ? "00.00" : formattedBalance)
            .contentTransition(.numericText(countsDown: true))
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(
                format == .fiat && satsPrice == 0 ? .secondary : .primary
            )
            .opacity(
                format == .fiat && satsPrice == 0 ? balanceTextPulsingOpacity : 1
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: format)
            .animation(.easeInOut, value: satsPrice)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    balanceTextPulsingOpacity = 0.3
                }
            }
    }

    private var unitText: some View {
        Text(format.displayText)
            .foregroundStyle(.secondary)
            .fontWeight(.thin)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
            .id("format-\(format)")
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: format)
    }

    init(format: BalanceDisplayFormat, balance: UInt64, fiatPrice: Double) {
        self.format = format
        self.balance = balance
        self.fiatPrice = fiatPrice
    }

    var body: some View {
        buildBalance()
    }

    @ViewBuilder
    private func buildBalance() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                if format != .sats && format != .bip21q {
                    currencySymbol
                }
                balanceText
                unitText
            }
            .font(.largeTitle)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .accessibilityLabel("Bitcoin Balance")
        .accessibilityValue(formattedBalance)
        .sensoryFeedback(.selection, trigger: format)
        .padding(.vertical, 35.0)
    }
}

#if DEBUG
    #Preview {
        BalanceView(
            format: .bip21q,
            balance: 5000,
            fiatPrice: 89000
        )
    }
#endif
