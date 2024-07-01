//
//  ResultViewController.swift
//  BKD Scanner
//
//  Created by Filip Siljavski on 26/08/22.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var scanResultLabel: UILabel!
    @IBOutlet weak var buttonsSeparator: UIView!
    @IBOutlet weak var resultTitleLabel: UILabel!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var okButtonTrailing: NSLayoutConstraint!
    
    var onOkBlock : (() -> Void)?
    var onContinueBlock : (() -> Void)?
    
    var resultTitle = "Scan result"
    var resultText: NSAttributedString?
    var isRecentsMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsSeparator.isHidden = isRecentsMode
        continueButton.isHidden = isRecentsMode
        okButtonTrailing.isActive = !isRecentsMode

        resultTitleLabel.text = resultTitle

        self.resultTextView.attributedText = resultText
        self.resultTextView.translatesAutoresizingMaskIntoConstraints = false
        self.resultTextView.isScrollEnabled = true
        
        let textInsets = 12.0
        self.resultTextView.textContainerInset = UIEdgeInsets(top: textInsets, left: textInsets, bottom: textInsets, right: textInsets)

        self.resize(textView: self.resultTextView)
        
        if #available(iOS 11.0, *) {
            let cornerRadius = 10.0
            
            okButton.layer.cornerRadius = cornerRadius
            okButton.layer.maskedCorners = isRecentsMode ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMaxYCorner]
            continueButton.layer.cornerRadius = cornerRadius
            continueButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
            scanResultLabel.layer.cornerRadius = cornerRadius
            scanResultLabel.layer.masksToBounds = true
            scanResultLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func onOkClick(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onOkBlock?()
        }
    }
    
    @IBAction func onContinueClick(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onContinueBlock?()
        }
    }
    
    fileprivate func resize(textView: UITextView) {
        let width = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let maxTextHeight = UIScreen.main.bounds.height * 0.8
        let textHeight = min(newSize.height, maxTextHeight)
        
        textViewHeightConstraint.constant = textHeight
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}
