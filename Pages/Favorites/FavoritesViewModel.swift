import Foundation

final class FavoritesViewModel {
    private(set) var favorites: [Movie] = []
    
    var languageCode: String {
           if #available(iOS 16.0, *) {
               return Locale.current.language.languageCode?.identifier.replacingOccurrences(of: "_", with: "-") ?? "en"
           } else {
               return Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
           }
       }
    var onDataUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func loadFavorites(completion: @escaping () -> Void = {}) {
        favorites = FavoritesManager.shared.fetchAllFavorites()
        updateLanguagesForFavorites {
            self.onDataUpdated?()
            completion()
        }
    }

    func updateLanguagesForFavorites(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for i in 0..<favorites.count {
            group.enter()
            updateFavoriteMovieLanguage(at: i) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }

    func updateFavoriteMovieLanguage(at index: Int, completion: @escaping (Bool) -> Void) {
        guard index >= 0 && index < favorites.count else {
            completion(false)
            return
        }

        let movie = favorites[index]

        MovieService.shared.fetchMovieDetail(id: movie.id) { [weak self] result in
            guard let self = self else {
                completion(false)
                return
            }
            switch result {
            case .success(let detailResponse):
                let newTitle = detailResponse.title
                let newPath = detailResponse.posterPath

                if !newTitle.isEmpty && newTitle != movie.title {
                    var updatedMovie = movie
                    updatedMovie.title = newTitle
                    updatedMovie.posterPath = newPath
                    FavoritesManager.shared.updateFavorite(movieId: movie.id, newTitle: newTitle,newPosterPath: newPath)
                    self.favorites[index] = updatedMovie

                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }

    func numberOfItems() -> Int {
        return favorites.count
    }
    
    func movie(at index: Int) -> Movie? {
        guard index >= 0 && index < favorites.count else {
            return nil
        }
        return favorites[index]
    }
    
    func removeFavorite(at index: Int) {
        guard index >= 0 && index < favorites.count else {
            return
        }
        
        let movie = favorites[index]
        FavoritesManager.shared.removeFavorite(movieId: movie.id)
        favorites.remove(at: index)
        NotificationCenter.default.post(name: .favoritesChanged, object: nil, userInfo: ["movieId": movie.id])
        onDataUpdated?()
    }
}
