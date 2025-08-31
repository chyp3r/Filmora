//
//  CoreData.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 31.07.2025.
//

import CoreData
import UIKit

// MARK: - Favorites Manager
final class FavoritesManager {
    
    // MARK: - Singleton
    static let shared = FavoritesManager()
    private init() {}
    
    // MARK: - Core Data Context
    lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: - CRUD Operations
    func addFavorite(movie: Movie) {
        let entity = FavoriteMovie(context: context)
        entity.id = Int64(movie.id)
        entity.title = movie.title
        entity.posterPath = movie.posterPath
        saveContext()
    }
    
    func removeFavorite(movieId: Int) {
        guard let fav = fetchFavorite(by: movieId) else { return }
        context.delete(fav)
        saveContext()
    }
    
    func updateFavorite(movieId: Int, newTitle: String, newPosterPath: String?) {
        guard let favorite = fetchFavorite(by: movieId) else { return }
        favorite.title = newTitle
        if let poster = newPosterPath {
            favorite.posterPath = poster
        }
        saveContext()
    }
    
    func fetchFavorite(by id: Int) -> FavoriteMovie? {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        return try? context.fetch(request).first
    }
    
    func fetchAllFavorites() -> [Movie] {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        let favorites = (try? context.fetch(request)) ?? []
        return favorites.map {
            Movie(
                id: Int($0.id),
                title: $0.title ?? "",
                posterPath: $0.posterPath,
                releaseDate: nil,
                voteAverage: nil,
                backdropPath: nil,
                overview: nil
            )
        }
    }
    
    // MARK: - Checks
    func isFavorite(movieId: Int) -> Bool {
        return fetchFavorite(by: movieId) != nil
    }
    
    func favoriteCount() -> Int {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
    
    // MARK: - Helpers
    private func saveContext() {
        do {
            try context.save()
        } catch {
        }
    }
}
