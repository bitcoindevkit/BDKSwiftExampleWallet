//
//  PriceService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

private struct PriceService {
    func historicalPrice() async throws -> PriceResponse {
        guard let url = URL(string: "https://mempool.space/api/v1/historical-price") else { throw PriceServiceError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode
        else { throw PriceServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(PriceResponse.self, from: data)
        return jsonObject
    }
    
    func prices() async throws -> Price {
        guard let url = URL(string: "https://mempool.space/api/v1/prices") else { throw PriceServiceError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode
        else { throw PriceServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(Price.self, from: data)
        return jsonObject
    }
}

enum PriceServiceError: Error {
    case invalidURL
    case invalidServerResponse
    case serialization
}

struct PriceAPIService {
    let fetchPrice: () async throws -> Price
    private init(fetchPrice: @escaping () async throws -> Price) {
        self.fetchPrice = fetchPrice
    }
}

extension PriceAPIService {
    static let live = Self(fetchPrice: { try await PriceService().prices() } )
}

#if DEBUG
let currentPriceMock = Price(time: 1693079705, usd: 26030, eur: 24508, gbp: 22486, cad: 35314, chf: 23088, aud: 40657, jpy: 3816606)
extension PriceAPIService {
    static let mock = Self(fetchPrice: { currentPriceMock })
}

#endif
