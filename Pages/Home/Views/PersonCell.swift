//
//  PersonCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 5.08.2025.
//

import UIKit

final class PersonCell: UICollectionViewCell {
    static let reuseIdentifier = CollectionView.Cells.personCell

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.backgroundColor = UIColor.systemGray5
        label.clipsToBounds = true
        label.layer.cornerRadius = 60
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorConstants.labelColor
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            placeholderLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 110),
            placeholderLabel.heightAnchor.constraint(equalTo: placeholderLabel.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Configure
    func configure(with person: PersonDetail, isDisplayed: Bool) {
        nameLabel.text = person.name

        if isDisplayed, let profilePath = person.profilePath, !profilePath.isEmpty {
            placeholderLabel.isHidden = true
            profileImageView.isHidden = false

            SkeletonImageLoader.loadImage(
                into: profileImageView,
                from: profilePath,
                baseUrl: ImageConstants.baseW200,
                placeholder: nil,
                skeletonBaseColor: .moviePink,
                fadeDuration: AnimationConstants.shortFadeDuration,
                cornerRadius: 40
            )
        } else {
            profileImageView.isHidden = true
            placeholderLabel.isHidden = false
            placeholderLabel.text = person.name.initials
        }
    }
    


    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = nil
        profileImageView.isHidden = false
        placeholderLabel.isHidden = true
        placeholderLabel.text = nil
        nameLabel.text = nil
    }
}
