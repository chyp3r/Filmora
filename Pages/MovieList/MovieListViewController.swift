//
//  MovieListViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import UIKit

// MARK: - MovieListViewController
final class MovieListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView! {
        didSet { tableView.backgroundColor = ColorConstants.primaryColor }
    }

    // MARK: - Properties
    private let viewModel: MovieListViewModel
    private var hasAnimatedCells = Set<IndexPath>()
    private var isLoading = false
    private var oldMovieCount = 0

    private lazy var errorView: ErrorStateView = {
        let view = ErrorStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return view
    }()

    // MARK: - Init
    init(viewModel: MovieListViewModel = MovieListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = MovieListViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupErrorView()
        bindViewModel()
        fetchMovies()
        title = TextConstants.moviesTitle

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesChanged(_:)),
            name: NotificationConstants.favoritesChanged,
            object: nil
        )
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: CollectionView.Cells.movieListNib, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CollectionView.Cells.movieListCell)
        tableView.showsVerticalScrollIndicator = false
    }

    private func setupErrorView() {
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.onMoviesUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorView.isHidden = true
                self.tableView.isHidden = false
                let newCount = self.viewModel.movies.count
                if newCount > self.oldMovieCount {
                    let newIndexPaths = (self.oldMovieCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: newIndexPaths, with: .automatic)
                }
                self.oldMovieCount = newCount
            }
        }

        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.tableView.isHidden = true
                self?.errorView.isHidden = false
            }
        }
    }

    // MARK: - Data Fetching
    private func fetchMovies() {
        guard !isLoading else { return }
        isLoading = true
        oldMovieCount = viewModel.movies.count
        viewModel.fetchMovies()
    }

    // MARK: - Actions
    @objc private func retryButtonTapped() {
        errorView.isHidden = true
        tableView.isHidden = false
        fetchMovies()
    }

    private func openDetail(for movie: Movie) {
        let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.movieDetailVCIdentifier) as? MovieDetailViewController else {
            return
        }
        detailVC.viewModel = MovieDetailViewModel(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc private func favoritesChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let movieId = userInfo["movieId"] as? Int,
              let index = viewModel.movies.firstIndex(where: { $0.id == movieId }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionView.Cells.movieListCell, for: indexPath) as? MovieListTableViewCell else {
            return UITableViewCell()
        }
        let movie = viewModel.movies[indexPath.row]
        cell.configure(with: movie)
        if indexPath.row == viewModel.movies.count - 5 { fetchMovies() }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !hasAnimatedCells.contains(indexPath) else { return }
        hasAnimatedCells.insert(indexPath)
        cell.layer.transform = CATransform3DMakeTranslation(0, tableView.bounds.height * AnimationConstants.favoritesCellTranslationY, 0)
        cell.alpha = 0
        UIView.animate(
            withDuration: AnimationConstants.favoritesCellAnimationDuration,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                cell.layer.transform = CATransform3DIdentity
                cell.alpha = 1
            }
        )
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        openDetail(for: movie)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
