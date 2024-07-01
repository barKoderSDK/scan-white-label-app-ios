//
//  WebhookConfigurationAlertViewController.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 8.11.23.
//

import UIKit

final class WebhookConfigurationAlertViewController: UIViewController {

    // MARK: - Private properties
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var webhookUrlTextfield: UITextField!
    @IBOutlet weak var webhookSecretTextfield: UITextField!
    @IBOutlet weak var howToButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    private var themeColor: UIColor = AppColor.brand.color
    
    private var showingAnimator: UIViewPropertyAnimator?
    private var hidingAnimator: UIViewPropertyAnimator?
    @IBOutlet weak var holderViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var holderViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAnimation()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground(_:))))

        let imageTextOffset: CGFloat = 2

        howToButton.layer.cornerRadius = 18
        howToButton.layer.borderWidth = 1
        howToButton.layer.borderColor = themeColor.cgColor
        howToButton.setTitleColor(themeColor, for: .normal)
        howToButton.setTitleColor(themeColor.withAlphaComponent(0.7), for: .highlighted)
        howToButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTextOffset, bottom: 0, right: imageTextOffset)
        howToButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextOffset, bottom: 0, right: -imageTextOffset)
        howToButton.setImage(
            UIImage(named: "information-circle")?
                .withRenderingMode(.alwaysTemplate), for: .normal
        )
        howToButton.tintColor = AppColor.brand.color
        
        saveButton.layer.cornerRadius = 18
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = themeColor.cgColor
        saveButton.setTitleColor(themeColor, for: .normal)
        saveButton.setTitleColor(themeColor.withAlphaComponent(0.7), for: .highlighted)
        saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTextOffset, bottom: 0, right: imageTextOffset)
        saveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextOffset, bottom: 0, right: -imageTextOffset)
        saveButton.setImage(UIImage(named: "arrow-path-rounded-square")?.withRenderingMode(.alwaysTemplate), for: .normal)
        saveButton.tintColor = AppColor.brand.color

        cancelButton.layer.cornerRadius = 18
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = themeColor.cgColor
        cancelButton.setTitleColor(themeColor, for: .normal)
        cancelButton.setTitleColor(themeColor.withAlphaComponent(0.7), for: .highlighted)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTextOffset, bottom: 0, right: imageTextOffset)
        cancelButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextOffset, bottom: 0, right: -imageTextOffset)
        cancelButton.setImage(
            UIImage(named: "close_24px")?
                .withRenderingMode(.alwaysTemplate), for: .normal
        )
        cancelButton.tintColor = AppColor.brand.color

        resetButton.layer.cornerRadius = 18
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = themeColor.cgColor
        resetButton.setTitleColor(themeColor, for: .normal)
        resetButton.setTitleColor(themeColor.withAlphaComponent(0.7), for: .highlighted)
        resetButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTextOffset, bottom: 0, right: imageTextOffset)
        resetButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextOffset, bottom: 0, right: -imageTextOffset)
        resetButton.setImage(
            UIImage(named: "arrow-path-rounded-square")?
                .withRenderingMode(.alwaysTemplate), for: .normal
        )
        resetButton.tintColor = AppColor.brand.color

        webhookUrlTextfield.setPaddingPoints(8)
        webhookUrlTextfield.returnKeyType = .done
        webhookUrlTextfield.keyboardType = .URL
        webhookUrlTextfield.text = UserDefaults.standard.getWebhookUrl()
        webhookUrlTextfield.delegate = self

        webhookSecretTextfield.setPaddingPoints(8)
        webhookSecretTextfield.returnKeyType = .done
        webhookSecretTextfield.text = UserDefaults.standard.getWebhookSecretWord()
        webhookSecretTextfield.isSecureTextEntry = true
        webhookSecretTextfield.delegate = self
    }
    
    private func setupAnimation() {
        showingAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.7, animations: {
            self.holderViewBottomConstraint.isActive = false
            self.holderViewCenterYConstraint.isActive = true
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.layoutIfNeeded()
        })
        
        hidingAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1.0, animations: {
            self.holderViewCenterYConstraint.isActive = false
            self.holderViewBottomConstraint.isActive = true
            self.view.backgroundColor = .clear
            self.view.layoutIfNeeded()
        })
        hidingAnimator?.addCompletion({ position in
            if position == .end {
                self.dismiss(animated: false)
            }
        })
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showingAnimator?.startAnimation()
        }
    }
    
    @objc
    private func didTapBackground(_ sender: UITapGestureRecognizer) {
        if webhookUrlTextfield.isFirstResponder {
            webhookUrlTextfield.resignFirstResponder()
        } else if webhookSecretTextfield.isFirstResponder {
            webhookSecretTextfield.resignFirstResponder()
        } else {
            let tapLocation = sender.location(in: self.holderView)
            
            if !holderView.bounds.contains(tapLocation) {
                hidingAnimator?.startAnimation()
            }
        }
    }
    
    @IBAction func howToButtonTapped(_ sender: Any) {
        SafariService.openDocsForWebhooks(self)
    }
    
    @IBAction func resetValueTapped(_ sender: Any) {
        UserDefaults.standard.clearWebhookData()
        
        hidingAnimator?.startAnimation()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let urlString = webhookUrlTextfield.text else { return }
        
        guard urlString.isValidURL() else {
            self.showAlertWith("Please enter valid URL")
            return
        }
        
        UserDefaults.standard.setWebhookUrl(urlString: urlString)
        UserDefaults.standard.setWebhookSecretWord(key: webhookSecretTextfield.text ?? "")

        hidingAnimator?.startAnimation()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hidingAnimator?.startAnimation()
    }
    
}

extension WebhookConfigurationAlertViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
