import Foundation

actor OMDbService {
    private let baseURL = "https://www.omdbapi.com"

    private var apiKey: String {
        APIConfig.omdbApiKey
    }

    func fetchRatings(imdbId: String) async throws -> OMDbResponse {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "i", value: imdbId),
            URLQueryItem(name: "plot", value: "short"),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OMDbError.invalidResponse
        }

        let omdbResponse = try JSONDecoder().decode(OMDbResponse.self, from: data)

        if omdbResponse.response == "False" {
            throw OMDbError.notFound(omdbResponse.error ?? "Unknown error")
        }

        return omdbResponse
    }
}

enum OMDbError: Error, LocalizedError {
    case invalidResponse
    case apiKeyMissing
    case notFound(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from OMDb API"
        case .apiKeyMissing:
            return "OMDb API key is not configured"
        case .notFound(let message):
            return "Content not found: \(message)"
        }
    }
}
