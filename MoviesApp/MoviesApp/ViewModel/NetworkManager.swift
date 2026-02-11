//
//  NetworkManager.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import Foundation

enum TMDbEndpoint {
    static let base = "https://api.themoviedb.org/3"
    static let imageBase = "https://image.tmdb.org/t/p/w500"

    static func popular(page: Int) -> String {
        "\(base)/movie/popular?page=\(page)"
    }
    static func search(query: String, page: Int) -> String {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return "\(base)/search/movie?query=\(q)&page=\(page)"
    }
    static func details(id: Int) -> String {
        "\(base)/movie/\(id)?append_to_response=credits,videos"
    }
    static func videos(id: Int) -> String {
        "\(base)/movie/\(id)/videos"
    }
}

final class TMDbClient {
    private let apiKeyV3: String
    private let readTokenV4: String

    init() {
        self.apiKeyV3 = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String ?? ""
        self.readTokenV4 = Bundle.main.object(forInfoDictionaryKey: "TMDB_READ_ACCESS_TOKEN") as? String ?? ""
        print("🔑 v3 key present? ->", !apiKeyV3.isEmpty, "| v4 read token present? ->", !readTokenV4.isEmpty)
    }

    func request<T: Decodable>(_ urlString: String) async throws -> T {
        guard var components = URLComponents(string: urlString) else { throw URLError(.badURL) }
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String ?? ""
        var qs = components.queryItems ?? []
        qs.append(URLQueryItem(name: "api_key", value: apiKey))
        components.queryItems = qs

        guard let url = components.url else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if let s = String(data: data, encoding: .utf8) { print("Server body:", s) }
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

}
