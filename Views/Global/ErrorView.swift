//
//  ErrorView.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 7.08.2025.
//

import UIKit

final class ErrorStateView: UIView {

    // MARK: - UI Elements
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.errorViewText
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextConstants.retryText, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        backgroundColor = ColorConstants.primaryColor
        addSubview(messageLabel)
        addSubview(retryButton)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
