//
//  HomeViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 5.08.2025.
//

import Foundation

class HomeViewModel {
    
    struct SectionData {
        var items: [Any]
        var currentPage: Int = 1
        var totalPages: Int = 1
        var isLoading: Bool = false
    }
    
    private var sectionData: [Section: SectionData] = [:]
    
    var onDataUpdated: (([Section: [Any]], [Section: [Any]]) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let movieService = MovieService.shared
    
    func items(for section: Section) -> [Any] {
        return sectionData[section]?.items ?? []
    }
    
    func fetchAll(reset: Bool = false) {
        let oldItemsBySection = self.collectCurrentItems()
        
        if reset {
            sectionData = [:]
        }
        
        let dispatchGroup = DispatchGroup()
        
        fetchHeroMovie(with: dispatchGroup)
        
        fetchMovies(for: .trending, with: dispatchGroup) { completion in
            self.movieService.fetchTrendingMovies(page: self.sectionData[.trending]?.currentPage ?? 1, completion: completion)
        }
        
        fetchMovies(for: .topRated, with: dispatchGroup) { completion in
            self.movieService.fetchTopRatedMovies(page: self.sectionData[.topRated]?.currentPage ?? 1, completion: completion)
        }
        
        fetchMovies(for: .popularMovies, with: dispatchGroup) { completion in
            self.movieService.fetchPopularMovies(page: self.sectionData[.popularMovies]?.currentPage ?? 1, completion: completion)
        }
        
        fetchMovies(for: .nowPlaying, with: dispatchGroup) { completion in
            self.movieService.fetchNowPlayingMovies(page: self.sectionData[.nowPlaying]?.currentPage ?? 1, completion: completion)
        }
        
        fetchMovies(for: .upcoming, with: dispatchGroup) { completion in
            self.movieService.fetchUpcomingMovies(page: self.sectionData[.upcoming]?.currentPage ?? 1, completion: completion)
        }
        
        fetchPersons(for: .popularPersons, with: dispatchGroup) { completion in
            self.movieService.fetchPopularPersons(page: self.sectionData[.popularPersons]?.currentPage ?? 1, completion: completion)
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let newItemsBySection = self.collectCurrentItems()
            self.onDataUpdated?(oldItemsBySection, newItemsBySection)
        }
    }
    
    private func fetchHeroMovie(with group: DispatchGroup) {
        group.enter()
        movieService.fetchTrendingMovies(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let movie = response.results.randomElement() {
                        self.sectionData[.hero] = SectionData(items: [movie], currentPage: 1, totalPages: 1)
                    }
                case .failure(let error):
                    self.onError?(error)
                }
                group.leave()
            }
        }
    }

    private func fetchMovies(for section: Section, with group: DispatchGroup, serviceCall: @escaping (@escaping (Result<MovieListResponse, Error>) -> Void) -> Void) {
        group.enter()
        sectionData[section]?.isLoading = true
        
        serviceCall { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.sectionData[section]?.isLoading = false
                
                switch result {
                case .success(let response):
                    var currentItems = self.sectionData[section]?.items ?? []
                    currentItems.append(contentsOf: response.results)
                    self.sectionData[section] = SectionData(
                        items: currentItems,
                        currentPage: response.page + 1,
                        totalPages: response.totalPages,
                        isLoading: false
                    )
                case .failure(let error):
                    self.onError?(error)
                }
                group.leave()
            }
        }
    }
    
    private func fetchPersons(for section: Section, with group: DispatchGroup, serviceCall: @escaping (@escaping (Result<PersonListResponse, Error>) -> Void) -> Void) {
        group.enter()
        sectionData[section]?.isLoading = true
        
        serviceCall { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.sectionData[section]?.isLoading = false
                
                switch result {
                case .success(let response):
                    var currentItems = self.sectionData[section]?.items ?? []
                    currentItems.append(contentsOf: response.results)
                    self.sectionData[section] = SectionData(
                        items: currentItems,
                        currentPage: response.page + 1,
                        totalPages: response.totalPages,
                        isLoading: false
                    )
                case .failure(let error):
                    self.onError?(error)
                }
                group.leave()
            }
        }
    }
    
    private func collectCurrentItems() -> [Section: [Any]] {
        var items: [Section: [Any]] = [:]
        for (section, data) in sectionData {
            items[section] = data.items
        }
        return items
    }
    
    enum Section: Int, CaseIterable, Hashable {
        case hero
        case trending
        case popularMovies
        case topRated
        case upcoming
        case nowPlaying
        case popularPersons
    }
    
    func numberOfSections() -> Int {
        return Section.allCases.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        return sectionData[section]?.items.count ?? 0
    }
    
    func movieForItem(at indexPath: IndexPath) -> Movie? {
        guard let section = Section(rawValue: indexPath.section), let items = sectionData[section]?.items else { return nil }
        return (items[safe: indexPath.item] as? Movie)
    }
    
    func personForItem(at indexPath: IndexPath) -> PersonDetail? {
        guard let section = Section(rawValue: indexPath.section), let items = sectionData[section]?.items else { return nil }
        return (items[safe: indexPath.item] as? PersonDetail)
    }
    
    func shouldLoadMore(at indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section), let data = sectionData[section] else { return false }
        
        return indexPath.item == data.items.count - 1 && data.currentPage <= data.totalPages && !data.isLoading
    }
    
    func loadMoreItems(for section: Section) {
        guard let data = sectionData[section],
              !data.isLoading,
              data.currentPage <= data.totalPages else {
            return
        }
        let oldItemsBySection = self.collectCurrentItems()

        let group = DispatchGroup()

        switch section {
        case .trending:
            fetchMovies(for: .trending, with: group) { completion in
                self.movieService.fetchTrendingMovies(page: data.currentPage, completion: completion)
            }
        case .topRated:
            fetchMovies(for: .topRated, with: group) { completion in
                self.movieService.fetchTopRatedMovies(page: data.currentPage, completion: completion)
            }
        case .popularMovies:
            fetchMovies(for: .popularMovies, with: group) { completion in
                self.movieService.fetchPopularMovies(page: data.currentPage, completion: completion)
            }
        case .popularPersons:
            fetchPersons(for: .popularPersons, with: group) { completion in
                self.movieService.fetchPopularPersons(page: data.currentPage, completion: completion)
            }
        case .nowPlaying:
            fetchMovies(for: .nowPlaying, with: group) { completion in
                self.movieService.fetchNowPlayingMovies(page: data.currentPage, completion: completion)
            }
        case .upcoming:
            fetchMovies(for: .upcoming, with: group) { completion in
                self.movieService.fetchUpcomingMovies(page: data.currentPage, completion: completion)
            }
        case .hero:
            break
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let newItemsBySection = self.collectCurrentItems()
            self.onDataUpdated?(oldItemsBySection, newItemsBySection)
        }
    }
}
