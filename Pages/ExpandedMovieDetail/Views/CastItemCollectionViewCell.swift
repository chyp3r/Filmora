//
//  CastItemCollectionViewCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 4.08.2025.
//

import UIKit
import Kingfisher

final class CastItemCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = CollectionView.Cells.casItemCell

    // MARK: - Properties
    private let avatarContainer: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConstants.detailPageBoxColor
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameOverlayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = ColorConstants.labelColor
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.backgroundColor = UIColor.systemGray5
        label.layer.cornerRadius = 40
        label.clipsToBounds = true
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = ColorConstants.labelColor
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 10)
        label.textColor = ColorConstants.secondaryLabelColor
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup Views
    private func setupViews() {
        contentView.addSubview(avatarContainer)
        avatarContainer.addSubview(imageView)
        avatarContainer.addSubview(nameOverlayLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)

        NSLayoutConstraint.activate([
            avatarContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 80),
            avatarContainer.heightAnchor.constraint(equalToConstant: 80),

            imageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),

            nameOverlayLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            nameOverlayLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            nameOverlayLabel.widthAnchor.constraint(equalToConstant: 80),
            nameOverlayLabel.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            roleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configure
    func configure(with cast: Cast) {
        nameLabel.text = cast.name
        
        if !cast.character.isEmpty {
            let cleanedRole = cast.character.replacingOccurrences(of: "\\s*\\([^)]*\\)", with: "", options: .regularExpression)
            roleLabel.text = cleanedRole
            roleLabel.isHidden = false
        } else {
            roleLabel.text = nil
            roleLabel.isHidden = true
        }
        
        if let profilePath = cast.profilePath, !profilePath.isEmpty {
            SkeletonImageLoader.loadImage(
                into: imageView,
                from: profilePath,
                baseUrl: ImageConstants.baseW200,
                placeholder: nil,
                skeletonBaseColor: .moviePink,
                fadeDuration: AnimationConstants.shortFadeDuration,
                cornerRadius: 8
            )
            imageView.isHidden = false
            nameOverlayLabel.isHidden = true
        } else {
            imageView.kf.cancelDownloadTask()
            imageView.image = nil
            imageView.isHidden = true
            
            nameOverlayLabel.text = cast.name.initials
            nameOverlayLabel.isHidden = false
        }
    }

    // MARK: - Cell Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        imageView.isHidden = false
        nameOverlayLabel.isHidden = true
        nameLabel.text = nil
        roleLabel.text = nil
        roleLabel.isHidden = true
    }
}
