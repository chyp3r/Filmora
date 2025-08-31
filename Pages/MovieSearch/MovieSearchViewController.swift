//
//  MovieSearchViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 31.07.2025.
//

import UIKit

// MARK: - MovieSearchViewController
final class MovieSearchViewController: UIViewController {

    // MARK: - Constants
    private enum CellIdentifier {
        static let search = TableView.Cells.searchCellIdentifier
    }

    // MARK: - Properties
    private let viewModel = MovieSearchViewModel()
    private var currentQuery = ""
    private var debounceTimer: Timer?
    
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateView = UIView()
    private let emptyMessageLabel = UILabel()
    private let emptyActionButton = UIButton(type: .system)
    private let errorStateView = ErrorStateView()
    
    private var recentSearches: [String] = [] {
        didSet { saveRecentSearches() }
    }
    private var isShowingRecentSearches = true

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecentSearches()
        bindViewModel()
        view.backgroundColor = ColorConstants.primaryColor
    }

    // MARK: - Setup UI
    private func setupUI() {
        setupSearchUI()
        setupTableView()
        setupEmptyStateView()
        setupErrorStateView()
    }

    private func setupSearchUI() {
        view.addSubview(searchContainerView)
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.backgroundColor = ColorConstants.inputTextFieldBackground
        searchContainerView.layer.cornerRadius = MovieSearchViewConstants.cornerRadius
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = TextConstants.searchPlaceHolder
        searchTextField.textColor = ColorConstants.labelColor
        searchTextField.tintColor = ColorConstants.labelColor
        searchTextField.font = FontConstants.searchBarFont
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocapitalizationType = .none
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        
        searchContainerView.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: MovieSearchViewConstants.searchContainerTopMargin),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MovieSearchViewConstants.searchContainerLeadingTrailingMargin),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -MovieSearchViewConstants.searchContainerLeadingTrailingMargin),
            searchContainerView.heightAnchor.constraint(equalToConstant: MovieSearchViewConstants.searchContainerHeight),
            
            searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: MovieSearchViewConstants.searchTextFieldHorizontalPadding),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -MovieSearchViewConstants.searchTextFieldHorizontalPadding),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ColorConstants.primaryColor
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.search)
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: TableView.Cells.recentSearchCellIdentifier)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: MovieSearchViewConstants.tableViewTopMargin),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyMessageLabel.textColor = ColorConstants.labelColor
        emptyMessageLabel.font = FontConstants.emptyMessageFont
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.numberOfLines = 0
        emptyMessageLabel.text = TextConstants.noResult
        
        emptyActionButton.translatesAutoresizingMaskIntoConstraints = false
        emptyActionButton.setTitle(TextConstants.tryFilmora, for: .normal)
        emptyActionButton.setTitleColor(.white, for: .normal)
        emptyActionButton.backgroundColor = ColorConstants.emptyActionButtonColor
        emptyActionButton.titleLabel?.font = FontConstants.emptyActionButtonFont
        emptyActionButton.layer.cornerRadius = 8
        emptyActionButton.addTarget(self, action: #selector(emptyActionTapped), for: .touchUpInside)
        
        emptyStateView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(emptyActionButton)
        
        NSLayoutConstraint.activate([
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyMessageLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyMessageLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -40),
            emptyMessageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: MovieSearchViewConstants.emptyStateMessageLeadingTrailingPadding),
            emptyMessageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -MovieSearchViewConstants.emptyStateMessageLeadingTrailingPadding),
            
            emptyActionButton.topAnchor.constraint(equalTo: emptyMessageLabel.bottomAnchor, constant: MovieSearchViewConstants.emptyMessageBottomMargin),
            emptyActionButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyActionButton.widthAnchor.constraint(equalToConstant: MovieSearchViewConstants.emptyActionButtonWidth),
            emptyActionButton.heightAnchor.constraint(equalToConstant: MovieSearchViewConstants.emptyActionButtonHeight)
        ])
    }

    private func setupErrorStateView() {
        view.addSubview(errorStateView)
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        errorStateView.isHidden = true
        errorStateView.retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            errorStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorStateView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            errorStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async { self?.updateUIAfterSearch() }
        }
        
        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async { self?.showErrorState() }
        }
        
        viewModel.onMovieSelected = { [weak self] movie in
            self?.navigateToDetail(movie)
        }
    }

    // MARK: - UI Updates
    private func updateUIAfterSearch() {
        errorStateView.isHidden = true
        emptyStateView.isHidden = !viewModel.movies.isEmpty
        tableView.isHidden = viewModel.movies.isEmpty
        tableView.reloadData()
    }
    
    private func showErrorState() {
        tableView.isHidden = true
        emptyStateView.isHidden = true
        errorStateView.isHidden = false
    }
    
    private func navigateToDetail(_ movie: Movie) {
        addRecentSearch(movie.title)
        let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
        if let movieDetailVC = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.movieDetailVCIdentifier) as? MovieDetailViewController {
            movieDetailVC.viewModel = MovieDetailViewModel(movie: movie)
            navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }

    // MARK: - Recent Searches
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: UserDefaultsConstants.recentSearches )
    }
    
    private func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: UserDefaultsConstants.recentSearches) {
            recentSearches = saved
        }
    }
    
    private func addRecentSearch(_ query: String) {
        guard !query.isEmpty else { return }
        if let index = recentSearches.firstIndex(of: query) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 10 {
            recentSearches.removeLast()
        }
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func emptyActionTapped() {
        tabBarController?.selectedIndex = 4
    }
    
    @objc private func retryTapped() {
        viewModel.searchMovies(query: currentQuery)
    }
}

// MARK: - UITextFieldDelegate
extension MovieSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else { return false }
        
        currentQuery = query
        addRecentSearch(query)
        isShowingRecentSearches = false
        searchTextField.resignFirstResponder()
        viewModel.searchMovies(query: query)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        debounceTimer?.invalidate()
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if text.isEmpty {
            isShowingRecentSearches = true
            tableView.reloadData()
            return
        }
        
        isShowingRecentSearches = false
        debounceTimer = Timer.scheduledTimer(withTimeInterval: MovieSearchViewConstants.debounceInterval, repeats: false) { [weak self] _ in
            self?.currentQuery = text
            self?.viewModel.searchMovies(query: text)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isShowingRecentSearches ? recentSearches.count : viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isShowingRecentSearches {
            let query = recentSearches[indexPath.row]
            searchTextField.text = query
            currentQuery = query
            addRecentSearch(query)
            isShowingRecentSearches = false
            viewModel.searchMovies(query: query)
        } else {
            let movie = viewModel.movies[indexPath.row]
            navigateToDetail(movie)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingRecentSearches {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.Cells.recentSearchCellIdentifier, for: indexPath) as! RecentSearchCell
            let query = recentSearches[indexPath.row]
            cell.titleLabel.text = query
            cell.onDeleteTapped = { [weak self] in
                guard let self = self else { return }
                if let index = self.recentSearches.firstIndex(of: query) {
                    self.recentSearches.remove(at: index)
                    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.search, for: indexPath)
            cell.backgroundColor = ColorConstants.primaryColor
            cell.textLabel?.textColor = ColorConstants.labelColor
            guard indexPath.row < viewModel.movies.count else { cell.textLabel?.text = nil; return cell }
            cell.textLabel?.text = viewModel.movies[indexPath.row].title
            return cell
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if position > (contentHeight - frameHeight - MovieSearchViewConstants.infiniteScrollTriggerOffset) {
            viewModel.loadMore()
        }
    }

    @objc private func deleteRecentSearch(_ sender: UIButton) {
        let index = sender.tag
        guard index < recentSearches.count else { return }
        recentSearches.remove(at: index)
        tableView.reloadData()
    }
}
