import UIKit

@IBDesignable
class MovieDetailOverlayView: UIView {

    private let gradientLayer = CAGradientLayer()

    @IBInspectable var cornerRadius: CGFloat = 16 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = false
        }
    }

    @IBInspectable var gradientOpacity: Float = 1 {
        didSet {
            gradientLayer.opacity = gradientOpacity
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = false

        gradientLayer.colors = [
            ColorConstants.primaryColor.withAlphaComponent(0.9).cgColor,
            ColorConstants.primaryColor.withAlphaComponent(0.7).cgColor,
            ColorConstants.primaryColor.withAlphaComponent(0.9).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.opacity = gradientOpacity
        layer.insertSublayer(gradientLayer, at: 0)

        layer.borderWidth = 1.2

        if traitCollection.userInterfaceStyle == .dark {
            layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.7
        } else {
            layer.borderColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 0.3
        }
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
