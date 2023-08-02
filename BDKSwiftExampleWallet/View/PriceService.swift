//
//  PriceService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

struct PriceService {
    func hourlyPrice() async throws -> PriceResponse {
        guard let url = URL(string: "https://mempool.space/api/v1/historical-price") else { throw PriceServiceError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode
        else { throw PriceServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(PriceResponse.self, from: data)
        return jsonObject
    }
}

enum PriceServiceError: Error {
    case invalidURL
    case invalidServerResponse
    case serialization
}
