//
//  CircularProgressView.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 13/06/25.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Float
    private let lineWidth: CGFloat = 2.0
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Text("\(Int(progress * 100))%")
                .contentTransition(.numericText())
                .font(.system(size: 9.0))
                .foregroundStyle(.secondary)
                .fontWeight(.regular)
        }
    }
}
