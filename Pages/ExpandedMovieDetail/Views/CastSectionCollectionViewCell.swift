//
//  CastSectionCollectionViewCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 4.08.2025.
//

import UIKit

final class CastSectionCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = CollectionView.Cells.castSectionCell

    // MARK: - UI Components
    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.castTitle
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = ColorConstants.labelColor
        return label
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.noInformation
        label.font = .italicSystemFont(ofSize: 15)
        label.textColor = ColorConstants.secondaryLabelColor
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Int, Cast>!
    
    weak var delegate: ExpandedMovieDetailViewController?

    // MARK: - Init
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 160)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        super.init(frame: frame)
        
        setupUI()
        setupDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(sectionLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(emptyLabel)

        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Setup DataSource
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CastItemCollectionViewCell, Cast> { cell, indexPath, cast in
            cell.configure(with: cast)
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, cast in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: cast)
        }
        
        collectionView.delegate = self
    }

    // MARK: - Configure
    func configure(with cast: [Cast]) {
        emptyLabel.isHidden = !cast.isEmpty
        collectionView.isHidden = cast.isEmpty
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Cast>()
        snapshot.appendSections([0])
        snapshot.appendItems(cast, toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension CastSectionCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cast = dataSource.itemIdentifier(for: indexPath) {
            delegate?.castSectionCell(self, didSelectCast: cast)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: AnimationConstants.shortFadeDuration) {
            cell.alpha = 1
        }
    }
}
