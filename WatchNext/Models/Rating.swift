import Foundation

struct OMDbResponse: Codable {
    let title: String?
    let year: String?
    let imdbRating: String?
    let imdbID: String?
    let ratings: [OMDbRating]?
    let response: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbRating
        case imdbID
        case ratings = "Ratings"
        case response = "Response"
        case error = "Error"
    }

    var imdbRatingDouble: Double? {
        guard let rating = imdbRating else { return nil }
        return Double(rating)
    }

    var rottenTomatoesScore: Int? {
        guard let ratings = ratings else { return nil }
        for rating in ratings {
            if rating.source == "Rotten Tomatoes" {
                let value = rating.value.replacingOccurrences(of: "%", with: "")
                return Int(value)
            }
        }
        return nil
    }
}

struct OMDbRating: Codable {
    let source: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}

struct Genre: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

struct GenresResponse: Codable {
    let genres: [Genre]
}

// MARK: - Company Models

struct Company: Identifiable, Codable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

struct CompanySearchResponse: Codable {
    let page: Int
    let results: [Company]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
