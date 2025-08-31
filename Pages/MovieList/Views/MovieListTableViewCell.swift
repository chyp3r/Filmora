//
//  MovieListTableViewCell.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//
import UIKit
import Kingfisher
import SkeletonView
import Cosmos

class MovieListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var favoriteIcon: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var cosmosView: CosmosView!
    
    var isFavorite: Bool = false;

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        posterImageView.clipsToBounds = true
        favoriteIcon.tintColor = .white
        containerView.backgroundColor = UIColor.moviePink.withAlphaComponent(0.05)
        backgroundColor = ColorConstants.primaryColor
        contentView.backgroundColor = ColorConstants.primaryColor
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        containerView.layer.masksToBounds = true
        let ribbon = DiagonalCornerRibbonView(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
        posterImageView.addSubview(ribbon)
        
        cosmosView.backgroundColor = .clear
        cosmosView.settings.fillMode = .half
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 4

        cosmosView.settings.filledColor = UIColor.systemYellow
        cosmosView.settings.filledBorderColor = UIColor.systemYellow.darker(by: 15)
        cosmosView.settings.emptyBorderColor = UIColor.systemYellow.withAlphaComponent(0.25)
        cosmosView.layer.shadowColor = UIColor.systemYellow.cgColor
        cosmosView.layer.shadowRadius = 4
        cosmosView.layer.shadowOpacity = 0.8
        cosmosView.layer.shadowOffset = CGSize(width: 0, height: 0)

        cosmosView.isUserInteractionEnabled = false

    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        releaseDateLabel.text = "\(TextConstants.releaseDate): \(formatDateToLocale(movie.releaseDate))"
        
        cosmosView.rating = (movie.voteAverage ?? 0.0) / 2.0
        
        SkeletonImageLoader.loadImage(
            into: posterImageView,
            from: movie.posterPath,
            baseUrl: ImageConstants.baseW200,
            placeholder: ImageConstants.filmPlaceHolder,
            skeletonBaseColor: .moviePink,
            fadeDuration: AnimationConstants.shortFadeDuration
        )

        isFavorite = FavoritesManager.shared.isFavorite(movieId: movie.id)
        favoriteIcon.image = UIImage(systemName: isFavorite ? NavigationBarConstant.heartFilledImageName:NavigationBarConstant.heartEmptyImageName)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
        cosmosView.rating = 0
    }
    
    func formatDateToLocale(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Unknown" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .short
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale.current
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return "Unknown"
        }
    }
    
}

class DiagonalCornerRibbonView: UIView {
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = bounds.width
        let h = bounds.height
        
        let cutoutHeight: CGFloat = h * 0.2
        let cutoutWidth: CGFloat = w * 0.6
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w / 2 + cutoutWidth / 2, y: h))
        path.addLine(to: CGPoint(x: w / 2, y: h-cutoutHeight))
        path.addLine(to: CGPoint(x: w / 2 - cutoutWidth / 2, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.close()
        
        shapeLayer.path = path.cgPath
    }
    
}
