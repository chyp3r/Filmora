//
//  CastDetailViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 31.07.2025.
//

import UIKit
import Kingfisher

final class CastDetailViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: CastDetailViewModel!
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: CastDetailViewConstants.blurStyle)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = CastDetailViewConstants.Profile.cornerRadius
        iv.clipsToBounds = true
        iv.layer.borderWidth = CastDetailViewConstants.Profile.borderWidth
        iv.layer.borderColor = ColorConstants.profileBorder.cgColor
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = FontConstants.bigInitialsFont
        label.textColor = ColorConstants.labelColor
        label.textAlignment = .center
        label.backgroundColor = ColorConstants.detailPageBoxColor
        label.clipsToBounds = true
        label.layer.cornerRadius = CastDetailViewConstants.Profile.cornerRadius
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = FontConstants.titleFont
        lbl.textColor = ColorConstants.whiteLabelColor
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let birthdayLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = FontConstants.bodyFont
        lbl.textColor = ColorConstants.whiteLabelColor
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let placeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = FontConstants.bodyFont
        lbl.textColor = ColorConstants.whiteLabelColor
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    
    private let bioLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = FontConstants.bodyFont
        lbl.textColor = ColorConstants.whiteLabelColor
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let errorView = ErrorStateView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        showLoading()
        viewModel.fetchPersonDetail()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = ColorConstants.primaryColor
        navigationController?.navigationBar.tintColor = .white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 12
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(scrollView)
        view.addSubview(profileImageView)
        view.addSubview(initialsLabel)
        view.addSubview(spinner)
        view.addSubview(errorView)
        
        // Spinner constraints
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Error view setup
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        errorView.retryButton.addTarget(self, action: #selector(retryFetch), for: .touchUpInside)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // ScrollView + ContentStack
        scrollView.addSubview(contentStackView)
        [nameLabel, birthdayLabel, placeLabel, bioLabel].forEach { contentStackView.addArrangedSubview($0) }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CastDetailViewConstants.Profile.topSpacing),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: CastDetailViewConstants.Profile.size),
            profileImageView.heightAnchor.constraint(equalToConstant: CastDetailViewConstants.Profile.size),

            initialsLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            initialsLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            initialsLabel.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            initialsLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoading()
                self?.errorView.isHidden = true
                if let detail = self?.viewModel.personDetail {
                    self?.configure(with: detail)
                }
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoading()
                self?.errorView.isHidden = false
                self?.clearUI()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func retryFetch() {
        errorView.isHidden = true
        viewModel.fetchPersonDetail()
    }
    
    // MARK: - UI State
    private func showLoading() {
        spinner.startAnimating()
        errorView.isHidden = true
    }
    
    private func hideLoading() {
        spinner.stopAnimating()
    }
    
    // MARK: - Configure UI
    private func configure(with detail: PersonDetail) {
        nameLabel.text = detail.name
        birthdayLabel.text = formatDate(detail.birthday, deathday: detail.deathday)
        placeLabel.text = detail.placeOfBirth ?? TextConstants.unknownPlace
        bioLabel.text = detail.biography?.isEmpty == false ? detail.biography : TextConstants.noBiography
        
        if let path = detail.profilePath,
           let url = ImageConstants.url(for: path, sizeBase: ImageConstants.baseW500) {
            let options: KingfisherOptionsInfo = [.transition(.fade(AnimationConstants.shortFadeDuration))]
            profileImageView.kf.setImage(with: url, options: options)
            backgroundImageView.kf.setImage(with: url, options: options)
            profileImageView.isHidden = false
            initialsLabel.isHidden = true
        } else {
            profileImageView.image = nil
            profileImageView.isHidden = true
            backgroundImageView.image = ImageConstants.filmPlaceHolder
            initialsLabel.text = detail.name.initials
            initialsLabel.isHidden = false
        }
    }
    
    private func clearUI() {
        nameLabel.text = nil
        birthdayLabel.text = nil
        placeLabel.text = nil
        bioLabel.text = nil
        profileImageView.image = nil
        initialsLabel.isHidden = true
    }
    
    // MARK: - Helpers
    private func formatDate(_ birthday: String?, deathday: String?) -> String {
        var parts = [String]()
        if let b = birthday, !b.isEmpty { parts.append("\(TextConstants.bornPrefix) \(b)") }
        if let d = deathday, !d.isEmpty { parts.append("\(TextConstants.diedPrefix) \(d)") }
        return parts.isEmpty ? TextConstants.dateUnavailable : parts.joined(separator: " • ")
    }
}
