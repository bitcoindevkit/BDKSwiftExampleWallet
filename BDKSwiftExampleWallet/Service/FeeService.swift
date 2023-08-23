//
//  FeeService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/23/23.
//

import Foundation

struct FeeService {
    func fees() async throws -> RecommendedFees {
        guard let url = URL(string: "https://mempool.space/api/v1/fees/recommended") else { throw FeeServiceError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode
        else { throw FeeServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(RecommendedFees.self, from: data)
        return jsonObject
    }
}

enum FeeServiceError: Error {
    case invalidURL
    case invalidServerResponse
    case serialization
}
