//
//  MessagesViewController.swift
//  AltCaps MessagesExtension
//
//  Created by Faraz Alam on 5/5/25.
//
// MessagesViewController.swift
// Updated with placeholder, haptics, and auto-send.

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {

    // MARK: – Subviews

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.15, alpha: 1)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let inputTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 18)
        tv.layer.cornerRadius = 12
        tv.clipsToBounds = true
        tv.isScrollEnabled = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Type your message here..."
        lbl.textColor = UIColor(white: 1, alpha: 0.4)
        lbl.font = .italicSystemFont(ofSize: 18)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let pasteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Paste", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let transformButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Transform & Add", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let feedbackLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Added Text!"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.alpha = 0        // start hidden
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let buttonStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        inputTextView.delegate = self
    }

    // MARK: – Layout

    private func setupUI() {
        view.addSubview(bubbleView)
        bubbleView.addSubview(inputTextView)
        bubbleView.addSubview(placeholderLabel)
        view.addSubview(buttonStack)
        view.addSubview(feedbackLabel)

        buttonStack.addArrangedSubview(pasteButton)
        buttonStack.addArrangedSubview(transformButton)
        
        let lead = bubbleView.leadingAnchor
              .constraint(equalTo: view.leadingAnchor, constant: 40)
        lead.priority = .required        // 1000

        let trail = bubbleView.trailingAnchor
              .constraint(equalTo: view.trailingAnchor, constant: -40)
        trail.priority = .defaultHigh    // 750

        NSLayoutConstraint.activate([
            // bubbleView
            lead, trail,
            bubbleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            bubbleView.heightAnchor.constraint(equalToConstant: 140),

            // inputTextView
            inputTextView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            inputTextView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            inputTextView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            inputTextView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),

            // placeholderLabel
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 5),
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 8),

            // buttonStack
            buttonStack.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            
            // feedbackLabel: centered under the stack
            feedbackLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 12),
            feedbackLabel.centerXAnchor.constraint(equalTo: buttonStack.centerXAnchor),

            // Transform button fixed width
            transformButton.widthAnchor.constraint(equalToConstant: 180)
        ])

        pasteButton.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
        transformButton.addTarget(self, action: #selector(transformTapped), for: .touchUpInside)
    }

    // MARK: – Actions

    @objc private func pasteTapped() {
        // This is a direct user action, so no "Allow Paste" prompt
        inputTextView.paste(nil)
    }

    @objc private func transformTapped() {
        let original = inputTextView.text ?? ""
        guard !original.isEmpty else {
            // you can still show the placeholder if you like
            return
        }
        let transformed = original.alternatingCaps
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        activeConversation?.insertText(transformed, completionHandler: nil)

        // show fading feedback
        showFeedback()
    }

    private func showFeedback() {
        feedbackLabel.layer.removeAllAnimations()
        feedbackLabel.alpha = 1
        UIView.animate(
          withDuration: 0.3,
          animations: { self.feedbackLabel.alpha = 1 }
        ) { _ in
          UIView.animate(
            withDuration: 1.5,
            delay: 0.5,
            options: [],
            animations: { self.feedbackLabel.alpha = 0 },
            completion: nil
          )
        }
    }

    // MARK: – Helpers

    private func showAlert(_ title: String, _ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: – UITextViewDelegate

extension MessagesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
