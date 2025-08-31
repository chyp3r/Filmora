//
//  FavoritesViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import UIKit

final class FavoritesViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = FavoritesViewModel()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    private let errorView = ErrorStateView()
    
    private let emptyStateView = UIView()
    private let emptyMessageLabel = UILabel()
    private let emptyActionButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TextConstants.favoritesTitle
        setupCollectionView()
        setupErrorView()
        setupEmptyStateView()
        configureDataSource()
        bindViewModel()
        setupNotifications()
        viewModel.loadFavorites()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Setup Methods
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = FavoritesViewConstants.minimumLineSpacing
        layout.minimumInteritemSpacing = FavoritesViewConstants.minimumInteritemSpacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = ColorConstants.primaryColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(FavoriteMovieCell.self, forCellWithReuseIdentifier: TableView.Cells.favoriteMoiveCellIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: FavoritesViewConstants.collecitonViewConstrait),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FavoritesViewConstants.collecitonViewConstrait),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FavoritesViewConstants.collecitonViewConstrait),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupErrorView() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        errorView.retryButton.addTarget(self, action: #selector(retryLoadFavorites), for: .touchUpInside)
    }

    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyMessageLabel.textColor = ColorConstants.labelColor
        emptyMessageLabel.font = FontConstants.emptyMessageFont
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.numberOfLines = 0
        emptyMessageLabel.text = TextConstants.noFavorite

        emptyActionButton.translatesAutoresizingMaskIntoConstraints = false
        emptyActionButton.setTitle(TextConstants.tryMovies, for: .normal)
        emptyActionButton.setTitleColor(.white, for: .normal)
        emptyActionButton.backgroundColor = ColorConstants.emptyActionButtonColor
        emptyActionButton.titleLabel?.font = FontConstants.emptyActionButtonFont
        emptyActionButton.layer.cornerRadius = 8
        emptyActionButton.addTarget(self, action: #selector(openPopularMovies), for: .touchUpInside)

        emptyStateView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(emptyActionButton)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyMessageLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyMessageLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -20),
            emptyMessageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            emptyMessageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20),
            
            emptyActionButton.topAnchor.constraint(equalTo: emptyMessageLabel.bottomAnchor, constant: 16),
            emptyActionButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyActionButton.widthAnchor.constraint(equalToConstant: 200),
            emptyActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { [weak self] collectionView, indexPath, movieId in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableView.Cells.favoriteMoiveCellIdentifier, for: indexPath) as? FavoriteMovieCell,
                  let movie = self.viewModel.favorites.first(where: { $0.id == movieId })
            else { return UICollectionViewCell() }

            cell.configure(with: movie)
            cell.delegate = self
            return cell
        }
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.errorView.isHidden = true
                let isEmpty = self.viewModel.favorites.isEmpty
                self.collectionView.isHidden = isEmpty
                self.emptyStateView.isHidden = !isEmpty
                self.applySnapshot()
            }
        }

        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.errorView.isHidden = false
                self?.collectionView.isHidden = true
                self?.emptyStateView.isHidden = true
            }
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesUpdated),
            name: NotificationConstants.favoritesChanged,
            object: nil
        )
    }

    // MARK: - Snapshot
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.favorites.map { $0.id }, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    // MARK: - Actions
    @objc private func retryLoadFavorites() {
        errorView.isHidden = true
        collectionView.isHidden = false
        emptyStateView.isHidden = true
        viewModel.loadFavorites()
    }

    @objc private func favoritesUpdated() { viewModel.loadFavorites() }
    
    @objc private func openPopularMovies() {
        tabBarController?.selectedIndex = 3
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = 24
        let interItemSpacing = 12
        let width = (collectionView.bounds.width - CGFloat(totalSpacing + interItemSpacing)) / 2
        let height = width * 3/2 + 40
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = viewModel.movie(at: indexPath.item) else { return }
        let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.movieDetailVCIdentifier) as? MovieDetailViewController {
            detailVC.viewModel = MovieDetailViewModel(movie: movie)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - FavoriteMovieCell Delegate
extension FavoritesViewController {
    func favoriteMovieCellDidTapRemove(_ cell: FavoriteMovieCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel.removeFavorite(at: indexPath.row)
        applySnapshot()
    }
}
