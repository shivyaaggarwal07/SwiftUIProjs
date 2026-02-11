//
//  MovieDetailsView.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import SwiftUI

struct MovieDetailView: View {
    @EnvironmentObject var favs: FavouritesStorage
    @StateObject private var vm: MovieDetailViewModel

    init(movieId: Int) {
        _vm = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let key = vm.trailerKey {
                    YouTubePlayerView(videoKey: key)
                        .frame(height: 220)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                if let d = vm.details {
                    header(d)
                    meta(d)
                    overview(d)
                    cast(d)
                } else if vm.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favs.toggle(vm.movieId)
                } label: {
                    Image(systemName: favs.isFavorite(vm.movieId) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear { vm.load() }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil), actions: {
            Button("OK") { vm.errorMessage = nil }
        }, message: { Text(vm.errorMessage ?? "") })
    }

    @ViewBuilder
    private func header(_ d: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(d.title).font(.title2).bold()
            HStack(spacing: 10) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text(String(format: "%.1f", d.voteAverage))
                if let runtime = d.runtime {
                    Text("· \(runtime) min")
                }
                if let year = d.releaseDate?.prefix(4) {
                    Text("· \(year)")
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func meta(_ d: MovieDetails) -> some View {
        if !d.genres.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(d.genres, id: \.id) { g in
                        Text(g.name)
                            .font(.caption)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }.padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private func overview(_ d: MovieDetails) -> some View {
        if !d.overview.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Plot").font(.headline)
                Text(d.overview).foregroundStyle(.secondary)
            }.padding(.horizontal)
        }
    }

    @ViewBuilder
    private func cast(_ d: MovieDetails) -> some View {
        if let cast = d.credits?.cast, !cast.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cast").font(.headline).padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(cast.prefix(15)) { member in
                            VStack(spacing: 6) {
                                ProfileImage(path: member.profilePath)
                                    .frame(width: 70, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Text(member.name).font(.caption).lineLimit(1)
                                if let c = member.character {
                                    Text(c).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                                }
                            }
                            .frame(width: 80)
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
}

struct ProfileImage: View {
    let path: String?
    var body: some View {
        if let path, let url = URL(string: TMDbEndpoint.imageBase + path) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .failure(_): placeholder
                case .empty: ProgressView()
                @unknown default: placeholder
                }
            }
        } else { placeholder }
    }
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "person.fill")
                .foregroundColor(.gray)
        }
    }
}

