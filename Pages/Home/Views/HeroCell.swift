//
//  HeroCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 5.08.2025.
//

import UIKit

final class HeroCell: UICollectionViewCell {
    static let reuseIdentifier = CollectionView.Cells.heroCell

    // MARK: - UI Elements
    private let backdropImageView = UIImageView()
    private let textBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let textStackView = UIStackView()

    var onViewMoreTapped: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false

        textBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textBackgroundView.isUserInteractionEnabled = false

        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = ColorConstants.labelColor
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        overviewLabel.font = .systemFont(ofSize: 14)
        overviewLabel.textColor = ColorConstants.labelColor
        overviewLabel.numberOfLines = 3
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.isUserInteractionEnabled = true

        textStackView.axis = .vertical
        textStackView.spacing = 8
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(overviewLabel)

        contentView.addSubview(backdropImageView)
        contentView.addSubview(textBackgroundView)
        contentView.addSubview(textStackView)

        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            textBackgroundView.topAnchor.constraint(equalTo: textStackView.topAnchor, constant: -8),
            textBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        updateTextBackground(animated: false)
    }

    @available(iOS, deprecated: 17.0)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateTextBackground(animated: true)
        }
    }

    private func updateTextBackground(animated: Bool) {
        let color: UIColor = traitCollection.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.8)
            : UIColor.white.withAlphaComponent(0.8)

        if animated {
            UIView.animate(withDuration: 0.25) { self.textBackgroundView.backgroundColor = color }
        } else {
            textBackgroundView.backgroundColor = color
        }
    }

    // MARK: - Configure
    func configure(with movie: Movie, isDisplayed: Bool) {
        titleLabel.text = movie.title

        if let overview = movie.overview, !overview.isEmpty {
            let maxLength = 140
            if overview.count > maxLength {
                let truncated = String(overview.prefix(maxLength)) + "... \(TextConstants.viewMore)"
                overviewLabel.attributedText = makeViewMoreText(truncated)
            } else {
                overviewLabel.text = overview
            }
        } else {
            overviewLabel.text = nil
        }
        
        if isDisplayed {
            SkeletonImageLoader.loadImage(
                into: backdropImageView,
                from: movie.backdropPath,
                baseUrl: ImageConstants.baseOriginal,
                placeholder: ImageConstants.filmIconImage,
                skeletonBaseColor: .moviePink,
                fadeDuration: AnimationConstants.shortFadeDuration
            )
        } else {
            backdropImageView.image = ImageConstants.nullPlaceHolder
        }
    }

    private func makeViewMoreText(_ text: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        if let range = text.range(of: TextConstants.viewMore) {
            let nsRange = NSRange(range, in: text)
            attributed.addAttributes([
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ], range: nsRange)
        }
        return attributed
    }
}
