//
//  FavouritesStorage.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import Foundation

final class FavouritesStorage: ObservableObject {
    @Published private(set) var ids: Set<Int> = []

    private let key = "favorite_movie_ids"

    init() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [Int] {
            self.ids = Set(saved)
        }
    }

    func toggle(_ id: Int) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        save()
    }

    func isFavorite(_ id: Int) -> Bool { ids.contains(id) }

    private func save() {
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
