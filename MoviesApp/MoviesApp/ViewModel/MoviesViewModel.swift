//
//  MoviesViewModel.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

// MoviesViewModel.swift
import Foundation

@MainActor
final class MoviesViewModel: ObservableObject {
    @Published var popular: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var runtimeCache: [Int: Int] = [:]
    private let client = TMDbClient()

    private var popularPage = 1
    private var searchPage = 1
    private var canLoadMorePopular = true
    private var canLoadMoreSearch = true
    private var searchTask: Task<Void, Never>?

    func loadPopular(reset: Bool = false) {
        guard !isLoading else { return }
        if reset {
            popularPage = 1
            canLoadMorePopular = true
            popular = []
        }
        guard canLoadMorePopular else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                struct Response: Decodable {
                    let page: Int
                    let results: [Movie]
                    let total_pages: Int
                }
                let resp: Response = try await client.request(TMDbEndpoint.popular(page: popularPage))
                popular.append(contentsOf: resp.results)
                popularPage += 1
                canLoadMorePopular = popularPage <= resp.total_pages
                print("Popular count now =", popular.count)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func prefetchRuntime(for id: Int) {
        guard runtimeCache[id] == nil else { return }
        Task {
            struct Details: Decodable { let runtime: Int? }
            do {
                let d: Details = try await client.request(TMDbEndpoint.details(id: id))
                runtimeCache[id] = d.runtime ?? 0
            } catch {
                // Cache 0 to avoid re-request loops
                runtimeCache[id] = 0
                print("Runtime fetch failed for \(id):", error.localizedDescription)
            }
        }
    }

    func search(text: String, reset: Bool = true) {
        query = text
        searchTask?.cancel()
        // Debounce ~300ms
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            await self?._performSearch(reset: reset)
        }
    }

    private func _performSearch(reset: Bool) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                self.searchResults = []
                self.searchPage = 1
                self.canLoadMoreSearch = true
            }
            return
        }
        if reset {
            searchPage = 1
            canLoadMoreSearch = true
            searchResults = []
        }
        guard canLoadMoreSearch, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            struct Response: Decodable {
                let page: Int
                let results: [Movie]
                let total_pages: Int
            }
            let resp: Response = try await client.request(TMDbEndpoint.search(query: query, page: searchPage))
            await MainActor.run {
                self.searchResults.append(contentsOf: resp.results)
                self.searchPage += 1
                self.canLoadMoreSearch = self.searchPage <= resp.total_pages
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }

    func loadMoreIfNeeded(currentItem item: Movie, isSearching: Bool) {
        let list = isSearching ? searchResults : popular
        if let idx = list.firstIndex(of: item), idx >= list.count - 5 {
            if isSearching { Task { await _performSearch(reset: false) } }
            else { loadPopular(reset: false) }
        }
    }
}
