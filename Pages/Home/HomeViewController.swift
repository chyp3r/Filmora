//
//  HomeViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 5.08.25.
//

import UIKit

// MARK: - HomeViewController
final class HomeViewController: UIViewController {

    // MARK: Properties
    private var viewModel = HomeViewModel()
    @IBOutlet private weak var collectionView: UICollectionView!

    private lazy var errorView: ErrorStateView = {
        let view = ErrorStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return view
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
        collectionView.isHidden = true
        collectionView.backgroundColor = ColorConstants.primaryColor
        title = TextConstants.homeTitle
        viewModel.fetchAll(reset: false)
    }

    // MARK: Setup
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            SectionLayoutBuilder.layout(for: sectionIndex)
        }
        collectionView.collectionViewLayout = layout
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: CollectionView.Cells.movieCell)
        collectionView.register(HeroCell.self, forCellWithReuseIdentifier: CollectionView.Cells.heroCell)
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: CollectionView.Cells.personCell)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionView.Cells.sectionHeader
        )
    }

    // MARK: Bind ViewModel
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] oldItemsBySection, newItemsBySection in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                
                if oldItemsBySection.isEmpty {
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.performBatchUpdates({
                        for (section, oldItems) in oldItemsBySection {
                            if let newItems = newItemsBySection[section] {
                                let oldItemsCount = oldItems.count
                                let newItemsCount = newItems.count
                                if newItemsCount > oldItemsCount {
                                    let indexPaths = (oldItemsCount..<newItemsCount).map {
                                        IndexPath(item: $0, section: section.rawValue)
                                    }
                                    self.collectionView.insertItems(at: indexPaths)
                                }
                            }
                        }
                    }, completion: nil)
                }
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.collectionView.isHidden = true
                self?.errorView.isHidden = false
            }
        }
    }
    
    @objc private func retryButtonTapped() {
        errorView.isHidden = true
        collectionView.isHidden = false
        viewModel.fetchAll(reset: true)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: Sections & Items
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    // MARK: Cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = HomeViewModel.Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        switch section {
        case .hero:
            guard let movie = viewModel.movieForItem(at: indexPath) else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.Cells.heroCell, for: indexPath) as! HeroCell
            cell.configure(with: movie, isDisplayed: false)
            cell.onViewMoreTapped = { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
                guard let movieDetailVC = storyboard.instantiateViewController(identifier: StoryboardConstants.movieDetailVCIdentifier) as? MovieDetailViewController else { return }
                movieDetailVC.viewModel = MovieDetailViewModel(movie: movie)
                self.navigationController?.pushViewController(movieDetailVC, animated: true)
            }
            return cell
            
        case .trending, .topRated, .popularMovies, .nowPlaying, .upcoming:
            guard let movie = viewModel.movieForItem(at: indexPath) else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.Cells.movieCell, for: indexPath) as! MovieCell
            cell.configure(with: movie, isDisplayed: false)
            return cell
            
        case .popularPersons:
            guard let person = viewModel.personForItem(at: indexPath) else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.Cells.personCell, for: indexPath) as! PersonCell
            cell.configure(with: person, isDisplayed: false)
            return cell
        }
    }

    // MARK: Headers
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CollectionView.Cells.sectionHeader,
            for: indexPath) as! SectionHeaderView
        
        let title: String
        switch HomeViewModel.Section(rawValue: indexPath.section) {
        case .hero: title = TextConstants.heroTitle
        case .trending: title = TextConstants.trendingTitle
        case .topRated: title = TextConstants.topRatedTitle
        case .popularMovies: title = TextConstants.popularMoviesTitle
        case .popularPersons: title = TextConstants.popularPersonsTitle
        case .nowPlaying: title = TextConstants.nowPlayingTitle
        case .upcoming: title = TextConstants.upcomingTitle
        case .none: title = ""
        }
        
        header.configure(with: title)
        return header
    }

    // MARK: Will Display
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let section = HomeViewModel.Section(rawValue: indexPath.section) else { return }
        if viewModel.shouldLoadMore(at: indexPath) {
            viewModel.loadMoreItems(for: section)
        }
        
        switch section {
        case .hero:
            if let heroCell = cell as? HeroCell, let movie = viewModel.movieForItem(at: indexPath) {
                heroCell.configure(with: movie, isDisplayed: true)
            }
        case .trending, .topRated, .popularMovies, .nowPlaying, .upcoming:
            if let movieCell = cell as? MovieCell, let movie = viewModel.movieForItem(at: indexPath) {
                movieCell.configure(with: movie, isDisplayed: true)
            }
        case .popularPersons:
            if let personCell = cell as? PersonCell, let person = viewModel.personForItem(at: indexPath) {
                personCell.configure(with: person, isDisplayed: true)
            }
        }
    }

    // MARK: Did Select
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = HomeViewModel.Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .hero, .trending, .topRated, .popularMovies, .nowPlaying, .upcoming:
            guard let movie = viewModel.movieForItem(at: indexPath) else { return }
            let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
            if let movieDetailVC = storyboard.instantiateViewController(identifier: StoryboardConstants.movieDetailVCIdentifier) as? MovieDetailViewController {
                movieDetailVC.viewModel = MovieDetailViewModel(movie: movie)
                navigationController?.pushViewController(movieDetailVC, animated: true)
            }
        case .popularPersons:
            guard let person = viewModel.personForItem(at: indexPath) else { return }
            let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
            if let castDetailVC = storyboard.instantiateViewController(identifier: StoryboardConstants.castDetailVCIdentifier) as? CastDetailViewController {
                castDetailVC.viewModel = CastDetailViewModel(personId: person.id)
                navigationController?.pushViewController(castDetailVC, animated: true)
            }
        }
    }
}

// MARK: - Section Layout Builder
private enum SectionLayoutBuilder {

    static func layout(for section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0: return Layouts.heroLayout()
        default: return Layouts.horizontalSliderLayout()
        }
    }

    private enum Layouts {

        static func heroLayout() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                 heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(HomeViewConstants.heroGroupHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            return section
        }

        static func horizontalSliderLayout() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(HomeViewConstants.sliderItemWidth),
                                                  heightDimension: .absolute(HomeViewConstants.sliderItemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = HomeViewConstants.sliderItemInsets

            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(HomeViewConstants.sliderGroupEstimatedWidth),
                                                   heightDimension: .absolute(HomeViewConstants.sliderGroupHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = HomeViewConstants.sliderSectionContentInsets

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(HomeViewConstants.sectionHeaderHeight))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }
    }
}
