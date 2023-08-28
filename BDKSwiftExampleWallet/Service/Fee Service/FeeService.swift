//
//  FeeService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/23/23.
//

import Foundation

private struct FeeService {
    func fees() async throws -> RecommendedFees {
        guard let url = URL(string: "https://mempool.space/api/v1/fees/recommended") else {
            throw FeeServiceError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else { throw FeeServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(RecommendedFees.self, from: data)
        return jsonObject
    }
}

struct FeeClient {
    let fetchFees: () async throws -> RecommendedFees
    private init(fetchFees: @escaping () async throws -> RecommendedFees) {
        self.fetchFees = fetchFees
    }
}

extension FeeClient {
    static let live = Self(fetchFees: { try await FeeService().fees() })
}

#if DEBUG
    let currentFeesMock = RecommendedFees(
        fastestFee: 10,
        halfHourFee: 8,
        hourFee: 6,
        economyFee: 4,
        minimumFee: 2
    )
    extension FeeClient {
        static let mock = Self(fetchFees: { currentFeesMock })
    }
#endif
