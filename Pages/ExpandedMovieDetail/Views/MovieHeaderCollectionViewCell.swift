//
//  MovieHeaderCollectionViewCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 4.08.2025.
//

import UIKit

final class MovieHeaderCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalInfoLabel: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!

    // MARK: - Properties
    static let reuseIdentifier = CollectionView.Cells.movieHeader

    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear

        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = ColorConstants.labelColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        originalInfoLabel.font = UIFont.italicSystemFont(ofSize: 16)
        originalInfoLabel.textColor =  ColorConstants.secondaryLabelColor
        originalInfoLabel.numberOfLines = 0
        originalInfoLabel.textAlignment = .center

        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        titleStackView.alignment = .center

        mainStackView.axis = .vertical
        mainStackView.spacing = 8
    }

    // MARK: - Configure
    func configure(with viewModel: ExpandedMovieDetailViewModel) {
        titleLabel.text = viewModel.title

        let languageCode = viewModel.originalLanguage
        let locale = Locale.current
        let languageName = locale.localizedString(forLanguageCode: languageCode) ?? languageCode

        originalInfoLabel.text = "\(viewModel.originalTitle)\n\(languageName.capitalized)"
    }

    // MARK: - Prepare For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        originalInfoLabel.text = nil
    }
}
