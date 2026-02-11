//
//  MoviesModel.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import Foundation

struct Movie: Identifiable, Decodable, Equatable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let genreIDs: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIDs = "genre_ids"
    }
}

//DETAILED MOVIE INFO
struct MovieDetails: Decodable {
    let id: Int
    let title: String
    let overview: String
    let genres: [Genre]
    let runtime: Int?
    let voteAverage: Double
    let releaseDate: String?
    let credits: Credits?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, runtime, credits
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct Credits: Decodable {
    let cast: [Cast]
}

struct Cast: Decodable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

//VIDEOS
struct VideoResponse: Decodable {
    let results: [Video]
}
struct Video: Decodable {
    let key: String
    let name: String
    let site: String
    let type: String
}
