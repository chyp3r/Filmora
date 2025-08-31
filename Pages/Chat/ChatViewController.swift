//
//  ChatViewController.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 6.08.2025.
//

import UIKit

final class ChatViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = ColorConstants.primaryColor
        tv.separatorStyle = .none
        tv.register(UITableViewCell.self, forCellReuseIdentifier: TableView.Cells.chatCellIdentifier)
        return tv
    }()
    
    private let inputContainerView = UIView()
    private let inputTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private let viewModel = ChatViewModel()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let label = UILabel()
        label.text = TextConstants.errorViewText
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.tag = ChatViewConstants.errorLabelTag
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(TextConstants.retryText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = ChatViewConstants.errorButtonTag
        
        view.addSubview(label)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: ChatViewConstants.errorLabelConstrait),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ChatViewConstants.errorLabelConstrait),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ChatViewConstants.errorLabelConstrait),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ChatViewConstants.errorLabelConstrait)
        ])
        
        return view
    }()
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TextConstants.chatTitle
        view.backgroundColor = ColorConstants.primaryColor
        tableView.backgroundColor = ColorConstants.primaryColor
        tableView.separatorStyle = .none
        
        setupTableView()
        setupInputComponents()
        setupLoadingIndicator()
        setupErrorView()
        bindViewModel()
        setupKeyboardObservers()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupInputComponents() {
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainerView)
        
        inputContainerView.backgroundColor = .clear
        
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: ChatViewConstants.inputLeftPaddingViewWidth, height: ChatViewConstants.inputTextFieldHeight))
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = .always
        inputTextField.placeholder = TextConstants.chatInputPlaceholder
        inputTextField.delegate = self
        
        inputTextField.backgroundColor = ColorConstants.inputTextFieldBackground
        inputTextField.textColor = ColorConstants.labelColor
        inputTextField.attributedPlaceholder = NSAttributedString(
            string: inputTextField.placeholder ?? "",
            attributes: [.foregroundColor: ColorConstants.inputPlaceholderColor]
        )
        inputTextField.layer.cornerRadius = ChatViewConstants.sendButtonCornerRadius
        inputTextField.clipsToBounds = true
        inputTextField.borderStyle = .none
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(TextConstants.sendButtonTitle, for: .normal)
        sendButton.setTitleColor(ColorConstants.labelColor, for: .normal)
        sendButton.backgroundColor = ColorConstants.inputTextFieldBackground
        sendButton.layer.cornerRadius = ChatViewConstants.sendButtonCornerRadius
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            inputContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: ChatViewConstants.inputContainerHeight)
        ])
        
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: ChatViewConstants.inputHorizontalPadding),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            inputTextField.heightAnchor.constraint(equalToConstant: ChatViewConstants.inputTextFieldHeight),
            
            sendButton.leadingAnchor.constraint(equalTo: inputTextField.trailingAnchor, constant: ChatViewConstants.inputHorizontalPadding),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -ChatViewConstants.inputHorizontalPadding),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: ChatViewConstants.sendButtonWidth)
        ])
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        tableViewBottomConstraint?.isActive = true
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
    }
    
    private func setupErrorView() {
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            errorView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        if let retryButton = errorView.viewWithTag(ChatViewConstants.errorButtonTag) as? UIButton {
            retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        }
    }
    
    private func bindViewModel() {
        viewModel.onMessagesUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.sendButton.isHidden = false
                self.inputTextField.isEnabled = true
                self.errorView.isHidden = true
                
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.sendButton.isHidden = false
                self?.inputTextField.isEnabled = true
                
                self?.errorView.isHidden = false
            }
        }
    }
    
    @objc private func retryButtonTapped() {
        errorView.isHidden = true
        if let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            sendButtonTapped()
        }
    }
    
    @objc private func sendButtonTapped() {
        guard let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        loadingIndicator.startAnimating()
        sendButton.isHidden = true
        inputTextField.isEnabled = false
        errorView.isHidden = true
        viewModel.sendMessage(text)
        inputTextField.text = ""
    }
    
    private func scrollToBottom() {
        let count = viewModel.numberOfMessages()
        guard count > 0 else { return }
        let idx = IndexPath(row: count - 1, section: 0)
        tableView.scrollToRow(at: idx, at: .bottom, animated: true)
    }
    
    // MARK: - Keyboard handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let keyboardHeight = frameValue.cgRectValue.height
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + self.view.safeAreaInsets.bottom)
            self.tableView.transform = .identity
            self.tableView.contentInset.bottom = keyboardHeight
        }
        scrollToBottom()
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = .identity
            self.tableView.transform = .identity
            self.tableView.contentInset.bottom = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - TableView DataSource / Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfMessages()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = viewModel.message(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.Cells.chatCellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        for v in cell.contentView.subviews { v.removeFromSuperview() }
        
        let bubbleView = UIView()
        bubbleView.backgroundColor = message.isUser ? ColorConstants.userBubbleBackground : ColorConstants.otherBubbleBackground
        bubbleView.layer.cornerRadius = ChatViewConstants.bubbleCornerRadius
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(bubbleView)
        
        let messageLabel = UILabel()
        messageLabel.text = message.text
        messageLabel.numberOfLines = 0
        messageLabel.textColor = message.isUser ? ColorConstants.whiteLabelColor : ColorConstants.secondaryLabelColor
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        let maxWidth = tableView.frame.width * ChatViewConstants.bubbleMaxWidthPercentage
        let padding = ChatViewConstants.bubblePadding
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
        ])
        
        if message.isUser {
            bubbleView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -ChatViewConstants.userBubbleTrailing).isActive = true
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: cell.contentView.leadingAnchor, constant: ChatViewConstants.userBubbleLeadingMin).isActive = true
        } else {
            bubbleView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: ChatViewConstants.otherBubbleLeading).isActive = true
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: cell.contentView.trailingAnchor, constant: -ChatViewConstants.otherBubbleTrailingMin).isActive = true
        }
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: padding),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: padding),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -padding),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -padding),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
        ])
        
        return cell
    }
}

// MARK: - TextField Delegate
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}
