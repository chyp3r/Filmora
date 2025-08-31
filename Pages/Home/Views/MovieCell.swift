//
//  MovieCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 5.08.2025.
//

import UIKit

final class MovieCell: UICollectionViewCell {
    static let reuseIdentifier = CollectionView.Cells.movieCell

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private var currentImageUrl: String?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = ColorConstants.labelColor
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    // MARK: - Configure
    func configure(with movie: Movie, isDisplayed: Bool) {
        titleLabel.text = movie.title
        titleLabel.numberOfLines = 3

        if isDisplayed {
            if currentImageUrl == movie.posterPath {return}
            SkeletonImageLoader.loadImage(
                into: posterImageView,
                from: movie.posterPath,
                baseUrl: ImageConstants.baseW200,
                placeholder: ImageConstants.filmPlaceHolder,
                skeletonBaseColor: .moviePink,
                fadeDuration: AnimationConstants.shortFadeDuration,
                cornerRadius: 8
            )
            currentImageUrl = movie.posterPath
        } else {
            if currentImageUrl == movie.posterPath {return}
            posterImageView.image = ImageConstants.filmPlaceHolder
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = ImageConstants.filmPlaceHolder
        titleLabel.text = nil
        currentImageUrl = nil
    }
}
