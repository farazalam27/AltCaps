//
//  MessagesViewController.swift
//  AlternatingCaps MessagesExtension
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
        v.backgroundColor = UIColor(white: 0.15, alpha: 1) // dark grey
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
        lbl.text = "Paste a message here…"
        lbl.textColor = UIColor(white: 1, alpha: 0.4)
        lbl.font = .italicSystemFont(ofSize: 18)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let transformButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Transform & Send", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        // placeholder sits on top of the text view
        bubbleView.addSubview(placeholderLabel)
        view.addSubview(transformButton)
        
        let leading = bubbleView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: 40)
        leading.priority = .required   // 1000

        let trailing = bubbleView.trailingAnchor
            .constraint(equalTo: view.trailingAnchor, constant: -40)
        trailing.priority = .defaultHigh  // 750

        NSLayoutConstraint.activate([
            // bubbleView
            leading, trailing,
            bubbleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            bubbleView.heightAnchor.constraint(equalToConstant: 140),
            
            // inputTextView inside bubble
            inputTextView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            inputTextView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            inputTextView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            inputTextView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),

            // placeholder aligned with textView’s inset
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 5),
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 8),

            // transformButton below bubble
            transformButton.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 20),
            transformButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transformButton.widthAnchor.constraint(equalToConstant: 180),
            transformButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        transformButton.addTarget(self, action: #selector(transformTapped), for: .touchUpInside)
    }

    // MARK: – Actions

    @objc private func transformTapped() {
        let original = inputTextView.text ?? ""
        let transformed = original.alternatingCaps

        // 1. Haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        // 2. Auto-send into Messages
        if let convo = activeConversation {
            convo.insertText(transformed) { error in
                if let err = error {
                    print("InsertText error:", err)
                }
                // dismiss UI so user sees the bubble collapse
                self.dismiss()
            }
        } else {
            // fallback: copy to clipboard
            UIPasteboard.general.string = transformed
        }
    }
}

// MARK: – UITextViewDelegate (for placeholder)

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
