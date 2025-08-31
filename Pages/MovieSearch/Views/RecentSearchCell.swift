//
//  RecentSearchCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 11.08.2025.
//

import UIKit

final class RecentSearchCell: UITableViewCell {
    
    // MARK: - UI
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontConstants.bodyFont
        label.textColor = ColorConstants.labelColor
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(ImageConstants.deleteIconImage, for: .normal)
        button.tintColor = ColorConstants.secondaryLabelColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Callback
    var onDeleteTapped: (() -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = ColorConstants.primaryColor
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(deleteButton)
        
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MovieSearchViewConstants.RecentCell.horizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: deleteButton.leadingAnchor,
                constant: -MovieSearchViewConstants.RecentCell.spacing
            ),
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: MovieSearchViewConstants.RecentCell.verticalPadding
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -MovieSearchViewConstants.RecentCell.verticalPadding
            ),

            deleteButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MovieSearchViewConstants.RecentCell.horizontalPadding
            ),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: MovieSearchViewConstants.RecentCell.deleteButtonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: MovieSearchViewConstants.RecentCell.deleteButtonSize)
        ])

    }
    
    // MARK: - Actions
    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
}
