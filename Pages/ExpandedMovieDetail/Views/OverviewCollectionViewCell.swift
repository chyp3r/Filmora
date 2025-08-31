//
//  OverviewCollectionViewCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 4.08.2025.
//

import UIKit

final class OverviewCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    static let reuseIdentifier = CollectionView.Cells.overviewCell

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.overviewTitle
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = ColorConstants.labelColor
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [overviewLabel])
        sv.axis = .vertical
        sv.alignment = .fill
        return sv
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, contentStack])
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

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
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configure
    func configure(text: String) {
        overviewLabel.text = text
        
        if text == TextConstants.noOverview {
            overviewLabel.textAlignment = .center
            contentStack.alignment = .center
            contentStack.isLayoutMarginsRelativeArrangement = true
            contentStack.layoutMargins = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
        } else {
            overviewLabel.textAlignment = .left
            contentStack.alignment = .fill
            contentStack.isLayoutMarginsRelativeArrangement = false
            contentStack.layoutMargins = .zero
        }
    }

    // MARK: - Prepare For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        overviewLabel.text = nil
    }
}
