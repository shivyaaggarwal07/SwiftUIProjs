//
//  MoviesDetailViewModel.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import Foundation

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var details: MovieDetails?
    @Published var trailerKey: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = TMDbClient()
    let movieId: Int

    init(movieId: Int) { self.movieId = movieId }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let d: MovieDetails = try await client.request(TMDbEndpoint.details(id: movieId))
                self.details = d
                let videos: VideoResponse = try await client.request(TMDbEndpoint.videos(id: movieId))
                self.trailerKey = videos.results.first(where: { $0.site == "YouTube" && $0.type.lowercased().contains("trailer") })?.key
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
