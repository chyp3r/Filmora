//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 29.07.2025.
//

import UIKit
import Kingfisher
import Lottie

// MARK: - MovieDetailViewController
final class MovieDetailViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: Properties
    var viewModel: MovieDetailViewModel! {
        didSet { bindViewModel() }
    }
    
    private var heartButton: UIBarButtonItem!
    weak var delegate: MovieListViewController?
    private var errorStateView: ErrorStateView?
    private var likeAnimationView: LottieAnimationView?

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearGenreRuntimeLabel: UILabel!
    @IBOutlet private weak var homepageButton: UIButton!
    @IBOutlet private weak var coverView: UIView!
    @IBOutlet private weak var navbarView: UIView!

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        coverView.isHidden = false
        navbarView.isHidden = true
        view.backgroundColor = ColorConstants.primaryColor
        setupNavigationBar()
        viewModel.fetchMovieDetails()
        navigationController?.delegate = self

        coverView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: coverView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        likeAnimationView?.stop()
        likeAnimationView?.removeFromSuperview()
        likeAnimationView = nil
    }

    // MARK: Setup
    private func setupGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesChanged(_:)),
            name: .favoritesChanged,
            object: nil
        )
    }

    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: NavigationBarConstant.backImageName),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )
        backButton.tintColor = ColorConstants.whiteLabelColor
        navigationItem.leftBarButtonItem = backButton
    }

    private func updateHeartButton(isFilled: Bool) {
        let imageName = isFilled ? NavigationBarConstant.heartFilledImageName : NavigationBarConstant.heartEmptyImageName
        heartButton = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: #selector(heartPressed)
        )
        heartButton.tintColor = isFilled ? .systemRed : ColorConstants.whiteLabelColor
        navigationItem.rightBarButtonItem = heartButton
    }

    // MARK: Bind ViewModel
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async { self?.updateUI() }
        }
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async { self?.showErrorAlert(error) }
        }
        viewModel.onBackRequested = { [weak self] in
            DispatchQueue.main.async { self?.navigationController?.popViewController(animated: true) }
        }
        viewModel.onHeartStateChanged = { [weak self] isFilled in
            DispatchQueue.main.async {
                self?.updateHeartButton(isFilled: isFilled)
                self?.showLikeAnimations(isFilled: isFilled)
            }
        }
        viewModel.onExpandedRequested = { [weak self] detail, cast, recs in
            DispatchQueue.main.async {
                self?.presentExpandedDetail(detail: detail, cast: cast, recommendations: recs)
            }
        }
    }

    // MARK: UI Updates
    private func updateUI() {
        guard let detail = viewModel.movieDetail else { return }
        titleLabel.text = detail.title
        let year = "📅 " + (detail.releaseDate?.split(separator: "-").first.map { String($0) } ?? TextConstants.notAvailable)
        let genre = "🎬 " + (detail.genres?.first?.name ?? TextConstants.notAvailable)
        let runtime = "⏱️ " + ((detail.runtime ?? 0) > 0 ? "\(detail.runtime!) \(TextConstants.timeShortening)" : TextConstants.notAvailable)


        let parts = [year, genre, runtime]
        yearGenreRuntimeLabel.attributedText = parts.joined(separator: "  |  ").coloredSeparators(for: traitCollection)

        SkeletonImageLoader.loadImage(
            into: posterImageView,
            from: detail.posterPath,
            baseUrl: ImageConstants.baseW500,
            placeholder: ImageConstants.nullPlaceHolder,
            skeletonBaseColor: .moviePink,
            fadeDuration: AnimationConstants.shortFadeDuration
        )

        if let homepage = detail.homepage, !homepage.isEmpty {
            homepageButton.setTitle(TextConstants.visitWebpageText, for: .normal)
            homepageButton.isEnabled = true
        } else {
            homepageButton.setTitle(TextConstants.noWebpageText, for: .disabled)
            homepageButton.isEnabled = false
        }

        activityIndicator.stopAnimating()
        coverView.isHidden = true
        navbarView.isHidden = false
        updateHeartButton(isFilled: viewModel.isHeartFilled)
        setupGestures()
    }

    private func showErrorAlert(_ error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        let errorView = ErrorStateView()
        errorView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        coverView.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        self.errorStateView = errorView
    }

    private func showLikeAnimations(isFilled: Bool) {
        guard isFilled else { return }
        likeAnimationView?.removeFromSuperview()
        let animationView = LottieAnimationView(name: "like")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 500),
            animationView.heightAnchor.constraint(equalToConstant: 500)
        ])
        likeAnimationView = animationView
        animationView.play { [weak self] finished in
            animationView.play(fromProgress: 1, toProgress: 0, loopMode: .playOnce) { finishedReverse in
                if finishedReverse {
                    animationView.removeFromSuperview()
                    self?.likeAnimationView = nil
                }
            }
        }
    }

    private func presentExpandedDetail(detail: MovieDetailResponse, cast: [Cast], recommendations: [Movie]) {
        let storyboard = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
        guard let expandedVC = storyboard.instantiateViewController(identifier: StoryboardConstants.expandedMovieDetailVCIdentifier) as? ExpandedMovieDetailViewController else { return }
        expandedVC.viewModel = ExpandedMovieDetailViewModel(movieDetail: detail, cast: cast, recommendations: recommendations)
        guard let nav = navigationController else { return }
        nav.delegate = self
        nav.pushViewController(expandedVC, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.navBarResetDelay) { nav.delegate = nil }
    }

    // MARK: Actions
    @IBAction private func homepageButtonTapped(_ sender: UIButton) {
        guard let urlString = viewModel.movieDetail?.homepage,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    @objc private func handleSwipeUp() { viewModel.userPulledUp() }
    @objc private func backPressed() { viewModel.backTapped() }
    @objc private func heartPressed() { if coverView.isHidden { viewModel.heartTapped() } }
    @objc private func screenDoubleTapped() { if coverView.isHidden { viewModel.heartTapped() } }
    @objc private func retryButtonTapped() {
        errorStateView?.removeFromSuperview()
        errorStateView = nil
        viewModel.fetchMovieDetails()
    }

    // MARK: Navigation Controller Delegate
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return VerticalSlideTransition(mode: .push)
        case .pop: return HorizontalSlideTransition(isForward: false)
        default: return nil
        }
    }
    
    @objc private func favoritesChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let updatedMovieId = userInfo["movieId"] as? Int,
              updatedMovieId == viewModel.movieDetail?.id else { return }
        
        viewModel.isHeartFilled = FavoritesManager.shared.isFavorite(movieId: updatedMovieId)
        updateHeartButton(isFilled: viewModel.isHeartFilled)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoritesChanged, object: nil)
    }
}
