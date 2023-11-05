//
//  ViewModel.swift
//  Fetch-Dessert
//
//  Created by Sasha Walkowski on 10/31/23.
//

import Foundation

class ViewModel: ObservableObject {
    func fetch() async throws -> [Dessert] {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DessertResponse.self, from: data)
            return decoded.desserts
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    func fetchDetails(id: String) async -> DessertDetails? {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DetailResponse.self, from: data)
            if let firstDetail = decoded.details.first {
                return firstDetail
            }
            return nil
        } catch {
            return nil
        }
    }
}

enum NetworkError: Error {
    case requestFailed
    case invalidResponse
    case decodingFailed
    case rateLimitExceeded
    case timeout
    case genericError(String)
    case invalidURL
    case networkError(Error)
}
