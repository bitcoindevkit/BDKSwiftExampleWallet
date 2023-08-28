//
//  PriceService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

private struct PriceService {
    func prices() async throws -> Price {
        guard let url = URL(string: "https://mempool.space/api/v1/prices") else {
            throw PriceServiceError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else { throw PriceServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(Price.self, from: data)
        return jsonObject
    }
}

struct PriceClient {
    let fetchPrice: () async throws -> Price
    private init(fetchPrice: @escaping () async throws -> Price) {
        self.fetchPrice = fetchPrice
    }
}

extension PriceClient {
    static let live = Self(fetchPrice: { try await PriceService().prices() })
}

#if DEBUG
    let currentPriceMock = Price(
        time: 1_693_079_705,
        usd: 26030,
        eur: 24508,
        gbp: 22486,
        cad: 35314,
        chf: 23088,
        aud: 40657,
        jpy: 3_816_606
    )
    let currentPriceMockZero = Price(
        time: 1_693_079_705,
        usd: 0,
        eur: 24508,
        gbp: 22486,
        cad: 35314,
        chf: 23088,
        aud: 40657,
        jpy: 3_816_606
    )
    extension PriceClient {
        static let mock = Self(fetchPrice: { currentPriceMock })
        static let mockPause = Self(fetchPrice: {
            try await Task.sleep(until: .now + .seconds(2))
            return currentPriceMock
        })
        static let mockZero = Self(fetchPrice: { currentPriceMockZero })
    }
#endif
