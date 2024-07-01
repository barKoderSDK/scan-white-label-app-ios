//
//  ResultDetailsViewController.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 6.10.23.
//

import UIKit
import Barkoder
import Toast

protocol ResultDetailsViewControllerDelegate: AnyObject {
    func didTap(action: ResultDetailsAction)
    func didRequestOpenSettings()
    func dismissedScreen()
}

extension ResultDetailsViewControllerDelegate {
    func dismissedScreen() {}
}

enum ResultDetailsAction {
    case copyValue(_ resultDetailsType: ResultDetailsViewController.ResultDetailsType)
    case webhook(_ resultDetailsType: ResultDetailsViewController.ResultDetailsType)
    case search(_ resultDetailsType: ResultDetailsViewController.ResultDetailsType)
    case sendCSVtoMail(_ resultDetailsType: ResultDetailsViewController.ResultDetailsType)
    case dismiss
}

final class ResultDetailsViewController: UIViewController {

    // MARK: - Public properties
    
    enum ResultDetailsType {
        case decoderTypes(result: ([DecoderResult], [UIImage]))
        case scanLog(scanLog: ScanLog)
    }
    
    // MARK: - Private properties
    
    private var themeColor: UIColor = AppColor.brand.color
    @IBOutlet weak private var holderView: UIView!
    @IBOutlet weak private var lineView: UIView!
    @IBOutlet weak private var symbologyLabel: UILabel!
    @IBOutlet weak private var valueLabel: UILabel!
    @IBOutlet weak private var barcodesQuantityLabel: UILabel!
    @IBOutlet weak private var holderViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var resultImageView: UIImageView!
    @IBOutlet weak private var holderViewBottomConstraints: NSLayoutConstraint!
    @IBOutlet private var resultImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var infoView: UIStackView!
    @IBOutlet private var infoTapImageView: UIImageView!
    @IBOutlet weak var expandButton: UIButton!
    private var showingAnimator: UIViewPropertyAnimator?
    private var dismissingAnimator: UIViewPropertyAnimator?
    private var partiallyShownAnimator: UIViewPropertyAnimator?
    
    @IBOutlet weak var upperStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var bottomStackViewHeightConstraint: NSLayoutConstraint!
    
    private var isShownInfoViewFirstTime = false
    /// Setting true/false starts showing with animation
    private var shouldShowInfoView = false {
        didSet {
            guard !isContinuousMode else { return }
            
            if self.shouldShowInfoView {
                guard !isShownInfoViewFirstTime else { return }
                
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    self.infoView.alpha = 0
                    self.infoView.isHidden = false

                    UIView.animate(withDuration: 0.15) {
                        self.infoView.alpha = 1
                        self.infoView.layoutIfNeeded()
                    }

                    self.isShownInfoViewFirstTime = true
                }
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.infoView.alpha = 0
                    self.infoView.layoutIfNeeded()
                } completion: { _ in
                    self.infoView.isHidden = true
                }
            }
        }
    }
    
    private var state: ResultBottomSheetState = .dismissed {
        didSet {
            setupAnimation()
            
            switch state {
            case .fullyShown:
                showingAnimator?.startAnimation()
                expandButton.isHidden = true
                resultImageView.isHidden = false
                shouldShowInfoView = true
            case .partiallyShown:
                partiallyShownAnimator?.startAnimation()
                expandButton.isHidden = false
                resultImageView.isHidden = true
                shouldShowInfoView = false
            case .dismissed:
                shouldShowInfoView = false
                dismissingAnimator?.startAnimation()
            }
        }
    }
    
    private var resultDetailsType: ResultDetailsType {
        didSet {
            switch resultDetailsType {
            case .decoderTypes(let result):
                let decoderResults = result.0
                let thumbnails = result.1
                
                symbologyLabel?.text = decoderResults.last?.barcodeTypeName
                valueLabel?.text = decoderResults.last?.textualData
                if decoderResults.count > 1 {
                    barcodesQuantityLabel?.text = "\(decoderResults.count) results found"
                }
                resultImageView.image = thumbnails.last
                resultImageViewHeightConstraint.constant = (thumbnails.count == 0)
                ? 0
                : 75
            case .scanLog(_):
                break
            }
        }
    }
    private var isContinuousMode: Bool
    
    // MARK: - Public properties
    
    weak var delegate: ResultDetailsViewControllerDelegate?
    
    // MARK: - Life cycle
    
    init(
        resultDetailsType: ResultDetailsType,
        isContinuousMode: Bool = false
    ) {
        self.resultDetailsType = resultDetailsType
        self.isContinuousMode = isContinuousMode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAnimation()
        setupUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showBottomSheet()
        }
    }
    
    private
    func setupAnimation() {
        showingAnimator?.stopAnimation(true)
        dismissingAnimator?.stopAnimation(true)
        showingAnimator = nil
        dismissingAnimator = nil
        
        showingAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.7, animations: {
            self.holderViewTopConstraint.isActive = false
            self.holderViewBottomConstraints.isActive = true
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            self.view.layoutIfNeeded()
        })
                
        partiallyShownAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .linear, animations: {
            self.holderViewBottomConstraints.isActive = false
            self.holderViewTopConstraint.constant = -110
            self.holderViewTopConstraint.isActive = true
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            self.view.layoutIfNeeded()
        })
        
        dismissingAnimator = UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.holderViewBottomConstraints.isActive = false
            self.holderViewTopConstraint.constant = 0
            self.holderViewTopConstraint.isActive = true
            self.view.backgroundColor = .clear
            self.view.layoutIfNeeded()
        })

        dismissingAnimator?.addCompletion({ _ in
            self.delegate?.dismissedScreen()
            self.dismiss(animated: false)
        })
    }

    private
    func setupUI() {
        infoTapImageView.image = UIImage(named: "ico-taptouch")?.withRenderingMode(.alwaysTemplate).withTintColor(.white)
        
        infoView.layer.cornerRadius = 25
        infoView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 16)
        infoView.isLayoutMarginsRelativeArrangement = true
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground(_:))))
        
        holderView.layer.cornerRadius = 24
        holderView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        holderView.addShadow()
        
        view.backgroundColor = .clear
        
        lineView.backgroundColor = .lightGray.withAlphaComponent(0.4)
        lineView.layer.cornerRadius = 2.5
        
        switch resultDetailsType {
        case .decoderTypes(let result):
            let decoderResults = result.0
            let thumbnails = result.1
            
            symbologyLabel?.text = decoderResults.last?.barcodeTypeName
            valueLabel?.text = decoderResults.last?.textualData
            if decoderResults.count > 1 {
                barcodesQuantityLabel?.text = "\(decoderResults.count) results found"
            }
            resultImageView.image = thumbnails.last
            resultImageViewHeightConstraint.constant = (thumbnails.count == 0)
            ? 0
            : 75
        case .scanLog(let scanLog):
            valueLabel.text = scanLog.value
            symbologyLabel.text = scanLog.symbology
            resultImageViewHeightConstraint.constant = 0
            barcodesQuantityLabel.text = nil
        }
                
        setButtons()
    }
    
    private
    func setButtons() {
        let copyValueButton = createButtonWith(
            "Copy",
            iconName: "ico-copy",
            action: #selector(didTapCopyValueButton)
        )
        let sendToMailButton = createButtonWith(
            "CSV",
            iconName: "ico-csv",
            action: #selector(sendToMailButton)
        )

        upperStackView.addArrangedSubview(copyValueButton)
        upperStackView.addArrangedSubview(sendToMailButton)
        
        var webhookButton: UIButton?
        if UserDefaults.standard.getWebhookFeatureEnabled() {
            webhookButton = createButtonWith(
                "Webhook",
                iconName: "ico-webhook",
                action: #selector(didTapWebhookButton)
            )
        }
        
        var searchButton: UIButton?
        if UserDefaults.standard.getSearchFeatureEnabled() {
            searchButton = createButtonWith(
                "Search",
                iconName: "ico-search",
                action: #selector(didTapSearchButton)
            )
        }
            
        switch ((webhookButton != nil), (searchButton != nil)) {
        case (true, true):
            bottomStackView.addArrangedSubview(webhookButton ?? UIView())
            bottomStackView.addArrangedSubview(searchButton ?? UIView())
        case (true, false):
            upperStackView.addArrangedSubview(webhookButton ?? UIView())
            
            bottomStackViewHeightConstraint.constant = 0
        case (false, true):
            upperStackView.addArrangedSubview(searchButton ?? UIView())
            
            bottomStackViewHeightConstraint.constant = 0
        default:
            bottomStackViewHeightConstraint.constant = 0
        }
    }
    
    private
    func createButtonWith(_ title: String, iconName: String, action: Selector) -> UIButton {
        let imageTextOffset: CGFloat = 2

        let button = UIButton()
        
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = themeColor.cgColor
        button.setTitleColor(themeColor, for: .normal)
        button.setTitleColor(themeColor.withAlphaComponent(0.7), for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTextOffset, bottom: 0, right: imageTextOffset)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextOffset, bottom: 0, right: -imageTextOffset)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor = themeColor

        return button
    }
    
    private
    func showBottomSheet() {
        state = .fullyShown
    }
    
    private
    func dismissBottomSheet(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.15) {
            self.holderViewBottomConstraints.isActive = false
            self.holderViewTopConstraint.isActive = true
            self.view.backgroundColor = .clear
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
            completion()
        }
    }
    
    @objc
    private func didTapSearchButton() {
        switch resultDetailsType {
        case .decoderTypes(let result):
            let scannedValue = result.0.last?.textualData ?? ""
            SafariService.searchWebFor(scannedValue, vc: self)
        case .scanLog(let scanLog):
            let scannedValue = scanLog.value ?? ""
            SafariService.searchWebFor(scannedValue, vc: self)
        }
    }
    
    @objc
    private func didTapCopyValueButton() {
        switch resultDetailsType {
        case .decoderTypes(let decoderType):
            let results = decoderType.0
                .compactMap { $0.textualData }
                .joined(separator: ", ")
            let pasteboard = UIPasteboard.general
            pasteboard.string = results
        case .scanLog(let scanLog):
            let pasteboard = UIPasteboard.general
            pasteboard.string = scanLog.value
        }

        view.makeToast("Value was copied to clipboard!")
    }
    
    @objc
    private func didTapWebhookButton() {
        switch resultDetailsType {
        case .decoderTypes(let result):
            let values = result.0.compactMap { ($0.barcodeTypeName ?? "N/A", $0.textualData ?? "N/A") }
            
            WebhookService.sendWebhook(values: values) { [weak self] result in
                switch result {
                case .success(let webhookResponse):
                    self?.showAlertWith(
                        webhookResponse.status ? "Success!" : "Invalid URL or Secret Key",
                        message: webhookResponse.message
                    )
                case .failure(let error):
                    if error.code == 418 {
                        guard let self else { return }
                        GeneralUtilities.showWebhookExplanationAlert(self, openSettingsCompletion: {
                            self.state = .dismissed
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                self.delegate?.didRequestOpenSettings()
                            }
                        })
                    } else {
                        self?.showAlertWith("Server error", message: error.description) 
                    }
                }
            }

        case .scanLog(let scanLog):
            let scannedValue = scanLog.value ?? ""
            let symbology = scanLog.symbology ?? ""
            WebhookService.sendWebhook(values: [(symbology, scannedValue)]) { [weak self] result in
                switch result {
                case .success(let webhookResponse):
                    self?.showAlertWith(
                        webhookResponse.status ? "Success!" : "Invalid URL or Secret Key",
                        message: webhookResponse.message
                    )
                case .failure(let error):
                    if error.code == 418 {
                        guard let self else { return }
                        GeneralUtilities.showWebhookExplanationAlert(self, openSettingsCompletion: {
                            self.state = .dismissed
                            self.delegate?.didRequestOpenSettings()
                        })
                    } else {
                        self?.showAlertWith("Server error", message: error.description)
                    }
                }
            }
        }
    }
    
    @objc
    private func sendToMailButton() {
        switch resultDetailsType {
        case .decoderTypes(let result):
            let decoderResults = result.0
            
            let resultsURL = BKDUtils.exportToCsv(decoderResults: decoderResults)
            
            let vc = MailServiceViewController(resultsURL: resultsURL)
            present(vc, animated: true)
        case .scanLog(let scanLog):
            let resultsURL = BKDUtils.exportToCsv(scanLog: scanLog)
            
            let vc = MailServiceViewController(resultsURL: resultsURL)
            present(vc, animated: true)
        }
    }
    
    @IBAction func didTapExpandButton(_ sender: Any) {
        state = .fullyShown
    }
    
    @objc
    private func didTapBackground(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.holderView)
        
        if !holderView.bounds.contains(tapLocation) {
            state = .dismissed
            
            delegate?.didTap(action: .dismiss)
        }
    }
    
    // MARK: - Public methods
    
    func updateWith(decoderResults: [DecoderResult], thumbnails: [UIImage]) {
        self.resultDetailsType = .decoderTypes(result: (decoderResults, thumbnails))
        
        state = .fullyShown
    }

}

fileprivate enum ResultBottomSheetState {
    case fullyShown
    case partiallyShown
    case dismissed
}
