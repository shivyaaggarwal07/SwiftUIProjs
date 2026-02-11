//
//  HomeView.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import SwiftUI
import WebKit

import SwiftUI
import WebKit

struct HomeView: View {
    @StateObject private var vm = MoviesViewModel()
    @StateObject private var favs = FavouritesStorage()

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: Binding(
                    get: { vm.query },
                    set: { vm.search(text: $0) }
                ))
                contentList
            }
            .navigationTitle("Movies")
            .onAppear { vm.loadPopular(reset: vm.popular.isEmpty) }
            .environmentObject(favs)
            .alert("Error", isPresented: .constant(vm.errorMessage != nil), actions: {
                Button("OK") { vm.errorMessage = nil }
            }, message: { Text(vm.errorMessage ?? "") })
        }
    }

    private var isSearching: Bool { !vm.query.trimmingCharacters(in: .whitespaces).isEmpty }

    @ViewBuilder
    private var contentList: some View {
        List {
            ForEach(isSearching ? vm.searchResults : vm.popular) { movie in
                NavigationLink {
                    MovieDetailView(movieId: movie.id)
                } label: {
                    MovieRow(movie: movie, runtime: vm.runtimeCache[movie.id])
                        .onAppear {
                            vm.prefetchRuntime(for: movie.id)
                            vm.loadMoreIfNeeded(currentItem: movie, isSearching: isSearching)
                        }
                }
            }
            if vm.isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .listStyle(.plain)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        TextField("Search movies...", text: $text)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .submitLabel(.search)
    }
}

struct MovieRow: View {
    @EnvironmentObject var favs: FavouritesStorage
    let movie: Movie
    let runtime: Int?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncPoster(path: movie.posterPath)
                .frame(width: 80, height: 120)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer()
                    Button {
                        favs.toggle(movie.id)
                    } label: {
                        Image(systemName: favs.isFavorite(movie.id) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                    if let date = movie.releaseDate, !date.isEmpty {
                        Text("· \(date.prefix(4))")
                    }
                    Text("· \(durationText)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                // If you want duration on list, you’d need an extra details fetch or cache. Optional for Home.
            }
        }
        .padding(.vertical, 6)
    }
    
    private var durationText: String {
            if let m = runtime, m > 0 { return "\(m) min" }
            return "--"
        }

}

struct AsyncPoster: View {
    let path: String?
    var body: some View {
        if let p = path, let url = URL(string: TMDbEndpoint.imageBase + p) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .failure(_): placeholder
                case .empty: ProgressView()
                @unknown default: placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "film")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    HomeView()
}
