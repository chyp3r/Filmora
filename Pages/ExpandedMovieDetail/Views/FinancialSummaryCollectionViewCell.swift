//
//  FinancialSummaryCollectionViewCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 5.08.2025.
//

import UIKit

final class FinancialSummaryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = CollectionView.Cells.financialCell
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.financialTitle
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = ColorConstants.labelColor
        return label
    }()
    
    private lazy var companiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ProductionCompanyCell.self, forCellWithReuseIdentifier: ProductionCompanyCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
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
    
    private let budgetBox = FinancialSummaryCollectionViewCell.makeInfoBox(title: TextConstants.budgetText, icon: ImageConstants.budgetIconImageName, color: .systemOrange)
    private let revenueBox = FinancialSummaryCollectionViewCell.makeInfoBox(title: TextConstants.revenueText, icon: ImageConstants.revenueIconImageName , color: .systemGreen)
    
    private let financialStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Data
    private var productionCompanies: [ProductionCompany] = []
    private var budgetValue: Int = 0
    private var revenueValue: Int = 0
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(companiesCollectionView)
        mainStackView.addArrangedSubview(emptyLabel)
        
        financialStackView.addArrangedSubview(budgetBox.container)
        financialStackView.addArrangedSubview(revenueBox.container)
        
        mainStackView.addArrangedSubview(financialStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            companiesCollectionView.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configure
    func configure(productionCompanies: [ProductionCompany], budget: Int, revenue: Int) {
        self.productionCompanies = productionCompanies
        self.budgetValue = budget
        self.revenueValue = revenue
        
        budgetBox.label.text = formatCurrencyShort(budget)
        revenueBox.label.text = formatCurrencyShort(revenue)
        
        let hasCompanies = !productionCompanies.isEmpty
        companiesCollectionView.isHidden = !hasCompanies
        emptyLabel.isHidden = hasCompanies
        
        companiesCollectionView.reloadData()
    }
    
    // MARK: - Helpers
    private func formatCurrencyShort(_ value: Int) -> String {
        let absValue = abs(Double(value))
        if absValue >= 1_000_000_000 {
            return String(format: "$%.1fB", absValue / 1_000_000_000)
        } else if absValue >= 1_000_000 {
            return String(format: "$%.1fM", absValue / 1_000_000)
        } else if absValue >= 1_000 {
            return String(format: "$%.1fK", absValue / 1_000)
        } else {
            return "$\(value)"
        }
    }
    
    private static func makeInfoBox(title: String, icon: String, color: UIColor) -> (container: UIView, label: UILabel) {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = ColorConstants.secondaryLabelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        valueLabel.textColor = color
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.numberOfLines = 1
        
        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            
            valueLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return (container, valueLabel)
    }
    
    // MARK: - Prepare For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        productionCompanies = []
        budgetValue = 0
        revenueValue = 0
        companiesCollectionView.reloadData()
        companiesCollectionView.isHidden = false
        emptyLabel.isHidden = true
        budgetBox.label.text = nil
        revenueBox.label.text = nil
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension FinancialSummaryCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        productionCompanies.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductionCompanyCell.reuseIdentifier, for: indexPath) as? ProductionCompanyCell else {
            return UICollectionViewCell()
        }
        let company = productionCompanies[indexPath.item]
        cell.configure(with: company)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 70)
    }
}
