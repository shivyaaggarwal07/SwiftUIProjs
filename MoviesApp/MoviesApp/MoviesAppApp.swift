//
//  MoviesAppApp.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 10/02/26.
//

import SwiftUI

@main
struct MoviesAppApp: App {
    @StateObject private var favorites = FavouritesStorage()
    var body: some Scene {
        WindowGroup {
            HomeView().environmentObject(favorites)
        }
    }
}
