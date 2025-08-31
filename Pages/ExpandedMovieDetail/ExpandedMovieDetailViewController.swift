//
//  ExpandedMovieDetailViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 30.07.2025.
//

import UIKit

final class ExpandedMovieDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet { collectionView.backgroundColor = ColorConstants.primaryColor }
    }

    // MARK: - Properties
    var viewModel: ExpandedMovieDetailViewModel!
    private var sizingHeaderCell: MovieHeaderCollectionViewCell?
    private let errorView = ErrorStateView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        setupErrorView()
        bindViewModel()
        setupSwipeDownGesture()
        navigationController?.delegate = self
        navigationItem.hidesBackButton = true
    }

    // MARK: - Setup Methods
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(
            UINib(nibName: CollectionView.Cells.movieHeaderNib, bundle: nil),
            forCellWithReuseIdentifier: CollectionView.Cells.movieHeader
        )
        collectionView.register(OverviewCollectionViewCell.self, forCellWithReuseIdentifier: OverviewCollectionViewCell.reuseIdentifier)
        collectionView.register(CastSectionCollectionViewCell.self, forCellWithReuseIdentifier: CastSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(RecommendationSectionCollectionViewCell.self, forCellWithReuseIdentifier: RecommendationSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(GenreSectionCollectionViewCell.self, forCellWithReuseIdentifier: GenreSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(FinancialSummaryCollectionViewCell.self, forCellWithReuseIdentifier: FinancialSummaryCollectionViewCell.reuseIdentifier)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = ExpandedMovieDetailViewConstants.minimumLineSpacing
        collectionView.collectionViewLayout = layout
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
        errorView.retryButton.addTarget(self, action: #selector(retryLoadData), for: .touchUpInside)
    }

    private func setupSwipeDownGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.onBackRequested = { [weak self] in
            guard let nav = self?.navigationController else { return }
            nav.delegate = self
            nav.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { nav.delegate = nil }
        }

        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.errorView.isHidden = true
                self?.collectionView.isHidden = false
                self?.collectionView.reloadData()
            }
        }

        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.errorView.isHidden = false
                self?.collectionView.isHidden = true
            }
        }
    }

    // MARK: - Actions
    @objc private func retryLoadData() {
        errorView.isHidden = true
        collectionView.isHidden = false
        viewModel.reloadData()
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        guard translation.y > 0, collectionView.contentOffset.y <= 0 else { return }
        if gesture.state == .ended { viewModel.backTapped() }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ExpandedMovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int { ExpandedMovieDetailViewConstants.Section.count }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = ExpandedMovieDetailViewConstants.Section(rawValue: indexPath.section) else { fatalError("Unknown section") }

        switch section {
        case .header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.Cells.movieHeader, for: indexPath) as! MovieHeaderCollectionViewCell
            cell.configure(with: viewModel)
            return cell

        case .genres:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreSectionCollectionViewCell.reuseIdentifier, for: indexPath) as! GenreSectionCollectionViewCell
            cell.configure(with: viewModel.genres)
            return cell

        case .overview:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewCollectionViewCell.reuseIdentifier, for: indexPath) as! OverviewCollectionViewCell
            cell.configure(text: viewModel.overview)
            return cell

        case .financialSummary:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FinancialSummaryCollectionViewCell.reuseIdentifier, for: indexPath) as! FinancialSummaryCollectionViewCell
            cell.configure(productionCompanies: viewModel.productionCompanies, budget: viewModel.budget, revenue: viewModel.revenue)
            return cell

        case .cast:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastSectionCollectionViewCell.reuseIdentifier, for: indexPath) as! CastSectionCollectionViewCell
            cell.configure(with: viewModel.cast)
            cell.delegate = self
            return cell

        case .recommendations:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationSectionCollectionViewCell.reuseIdentifier, for: indexPath) as! RecommendationSectionCollectionViewCell
            cell.configure(with: viewModel.recommendations)
            cell.delegate = self
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        guard let section = ExpandedMovieDetailViewConstants.Section(rawValue: indexPath.section) else { return .zero }

        switch section {
        case .header:
            if sizingHeaderCell == nil {
                sizingHeaderCell = Bundle.main.loadNibNamed(CollectionView.Cells.movieHeaderNib, owner: nil, options: nil)?.first as? MovieHeaderCollectionViewCell
            }
            guard let prototype = sizingHeaderCell else { return CGSize(width: width, height: 240) }
            prototype.configure(with: viewModel)
            prototype.bounds.size.width = width
            prototype.setNeedsLayout()
            prototype.layoutIfNeeded()
            let fitting = prototype.contentView.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return CGSize(width: width, height: ceil(fitting.height))

        case .genres: return CGSize(width: width, height: viewModel.genres.isEmpty ? 1 : 56)
        case .overview:
            let dummyCell = OverviewCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: 0))
            dummyCell.configure(text: viewModel.overview)
            let size = dummyCell.contentView.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return CGSize(width: width, height: size.height)
        case .financialSummary: return CGSize(width: width, height: 250)
        case .cast: return CGSize(width: width, height: viewModel.cast.isEmpty ? 150 : 220)
        case .recommendations: return CGSize(width: width, height: viewModel.recommendations.isEmpty ? 150 : 320)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ExpandedMovieDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}

// MARK: - UINavigationControllerDelegate
extension ExpandedMovieDetailViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return VerticalSlideTransition(mode: .push)
        case .pop: return VerticalSlideTransition(mode: .pop)
        default: return nil
        }
    }
}

// MARK: - Section Cell Delegates
extension ExpandedMovieDetailViewController {
    func castSectionCell(_ cell: CastSectionCollectionViewCell, didSelectCast cast: Cast) {
        let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
        guard let castVC = storyboard.instantiateViewController(identifier: StoryboardConstants.castDetailVCIdentifier) as? CastDetailViewController else { return }
        castVC.viewModel = CastDetailViewModel(personId: cast.id)
        navigationController?.pushViewController(castVC, animated: true)
    }

    func recommendationSectionCell(_ cell: RecommendationSectionCollectionViewCell, didSelectRecommendation movie: Movie) {
        let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
        guard let movieDetailVC = storyboard.instantiateViewController(identifier: StoryboardConstants.movieDetailVCIdentifier) as? MovieDetailViewController else { return }
        movieDetailVC.viewModel = MovieDetailViewModel(movie: movie)
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}
