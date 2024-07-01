//
//  ScannerViewController.swift
//  BKD Scanner
//

import UIKit
import BarkoderSDK
import AVFoundation
import MessageUI
import Toast

enum BarcodeConfigs {
    case oneD
    case twoD
    case ffa
}

class ScannerViewController: UIViewController, BarkoderResultDelegate {
    
    private static let ZOOM_ON_VAL = 3
    private static let ZOOM_OFF_VAL = 1
    
    @IBOutlet weak var barkoderView: BarkoderView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var barkoderLogo: UIImageView!
    @IBOutlet weak var symbologiesLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var sessionResultsTextView: UITextView!
    @IBOutlet weak var numberOfScans: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var multiScanDelayLabel: UILabel!
    private var shouldShowImage: Bool = false {
        didSet {
            resultImageView.isHidden = !shouldShowImage
            if !shouldShowImage {
                resultImageView.image = nil
            }
        }
    }
    
    var config: BarkoderConfig?
    var settingsType: SettingsViewController.SettingsType = .all
    
    private var currentZoom = ZOOM_OFF_VAL {
        didSet {
            let imageName = currentZoom == ScannerViewController.ZOOM_OFF_VAL ? "btn-zoom-on" : "btn-zoom-off"
            zoomButton.setImage(UIImage(named: imageName), for: .normal)
            
            zoomButton.backgroundColor = currentZoom != ScannerViewController.ZOOM_OFF_VAL ? AppColor.brand.color : .clear
            zoomButton.layer.borderColor = AppColor.brand.color.cgColor
            zoomButton.layer.borderWidth = currentZoom != ScannerViewController.ZOOM_OFF_VAL ? 0 : 1.5
            zoomButton.layer.cornerRadius = 6

            self.barkoderView.setZoomFactor(Float(currentZoom))
        }
    }
    private var isFlashActive = false {
        didSet {
            let imageName = isFlashActive ? "btn-flash-on" : "btn-flash-off"
            flashButton.setImage(UIImage(named: imageName), for: .normal)
            flashButton.backgroundColor = isFlashActive ? AppColor.brand.color : .clear
            flashButton.layer.borderColor = AppColor.brand.color.cgColor
            flashButton.layer.borderWidth = isFlashActive ? 0 : 1.5
            flashButton.layer.cornerRadius = 6
            barkoderView.setFlash(isFlashActive)
        }
    }
    private var presentedResultDetailsViewController: ResultDetailsViewController?
    private var isPresentingBottomSheetInProgress: Bool = false
    private var resultsInSession: [DecoderResult] = []
    private var thumbnailsInSession: [UIImage] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        checkCameraPermission { granted in
            self.barkoderView.config = self.config
            self.barkoderView.config?.barcodeThumbnailOnResult = true
            self.barkoderView.config?.imageResultEnabled = true
            self.updateActiveSymbologiesText()
            self.updateMultiScanDelayLabel()
            if UserDefaults.standard.getFpsFeatureEnabled() {
                self.barkoderView.setBarkoderPerformanceDelegate(self)
            }
            try? self.barkoderView.startScanning(self)
            
            if !granted {
                self.showPermissionAlert()
            }
        }
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func checkCameraPermission(finished: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            finished(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    finished(granted)
                }
            }
        case .denied:
            DispatchQueue.main.async {
                finished(false)
            }
        default:
            break
        }
    }

    private func setupUI () {
        expandButton.setImage(
            UIImage(named: "ico-arrow-up")?
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.white),
            for: .normal)
        expandButton.tintColor = .white
        expandButton.isHidden = true
        
        numberOfScans.isUserInteractionEnabled = true
        numberOfScans.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNumberOfScansLabel)))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        barkoderView.addGestureRecognizer(tapGesture)
    }
    
    private func updateMultiScanDelayLabel() {
        if let thresholdBetweenDuplicatesScans = config?.thresholdBetweenDuplicatesScans,
           config?.closeSessionOnResultEnabled == false,
           thresholdBetweenDuplicatesScans >= 1
        {
            multiScanDelayLabel.text = String(format: "Continuous / %@s delay", String(thresholdBetweenDuplicatesScans))
        } else {
            multiScanDelayLabel.text = nil
        }
    }
    
    @objc
    private func didTapBackground() {
        startScanningIfNeeded()
    }
    
    @objc
    private func didTapNumberOfScansLabel() {
        showResult(decoderResults: resultsInSession, thumbnails: thumbnailsInSession, forceOpen: true)
    }
    
    @IBAction func didTapExpandButton(_ sender: Any) {
        showResult(decoderResults: resultsInSession, thumbnails: thumbnailsInSession, forceOpen: true)
    }
    
    private func adjustRoi() {
        guard let config = config else { return }
                
        let fullScreenRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let defaultScreenRect = CGRect(x: 3, y: 20, width: 94, height: 60)
		let dotcodeScreenRect = CGRect(x: 30, y: 40, width: 40, height: 9)
        
        switch settingsType {
        case .all, .general, .batch, .showcase:
            try? config.setRegionOfInterest(config.regionOfInterestVisible ? defaultScreenRect : fullScreenRect)
        case .template(let template):
            switch template {
            case .all:
                try? config.setRegionOfInterest(config.regionOfInterestVisible ? defaultScreenRect : fullScreenRect)
            case .qr:
                config.regionOfInterestVisible = true
                try? config.setRegionOfInterest(defaultScreenRect)
            case .all_2d:
                config.regionOfInterestVisible = true
                try? config.setRegionOfInterest(defaultScreenRect)
            case .dpm:
                let dpmScreenRect = UserDefaults.standard.getDpmBiggerViewFinder()
                ? CGRect(x: 35, y: 40, width: 30, height: 14)
                : CGRect(x: 40, y: 40, width: 20, height: 9)

                config.regionOfInterestVisible = true
                try? config.setRegionOfInterest(dpmScreenRect)
            case .vin:
                let dpmScreenRect = UserDefaults.standard.getVinNarrowViewFinder()
                ? CGRect(x: 0, y: 35, width: 100, height: 30)
                : fullScreenRect

                config.regionOfInterestVisible = true
                try? config.setRegionOfInterest(dpmScreenRect)
			case .dotcode:
				config.regionOfInterestVisible = true
				try? config.setRegionOfInterest(dotcodeScreenRect)
            default:
                try? config.setRegionOfInterest(fullScreenRect)
            }
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustRoi()
    }
    
    fileprivate func appendResultLines(_ decoderResults: [DecoderResult]) {
        for result in decoderResults {
            let symbologyTypeString = NSAttributedString(string: "\n\(result.barcodeTypeName ?? "Unknown"): ", attributes: [.foregroundColor: UIColor.red])
            let textualDataString = NSAttributedString(string: "\(result.getParsedResultOrTextual())", attributes: [.foregroundColor: UIColor.white])
            
            let currentText = sessionResultsTextView.attributedText.mutableCopy() as! NSMutableAttributedString
            currentText.append(symbologyTypeString)
            currentText.append(textualDataString)
            
            sessionResultsTextView.attributedText = currentText.copy() as? NSAttributedString
            scrollTextViewToBottom(textView: sessionResultsTextView)
        }
    }
    
    func scanningFinished(_ decoderResults: [DecoderResult], thumbnails: [UIImage]?, image: UIImage?) {
        if let closeSessionOnResultEnabled = config?.closeSessionOnResultEnabled, closeSessionOnResultEnabled == true {
            resultImageView.image = image
            shouldShowImage = true
        }
        
        let resultTexts = NSMutableAttributedString()
        for (index, result) in decoderResults.enumerated() {
            if index > 0 {
                resultTexts.append(NSAttributedString(string: "\n\n"))
            }
            
            let resultText = result.getParsedResultOrTextual()
            
            resultTexts.append(NSAttributedString(string: "\(result.barcodeTypeName ?? "")\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
            resultTexts.append(NSAttributedString(string: resultText))

            CoreDataHelper.saveScanLog(value: resultText, symbology: result.barcodeTypeName)
        }
        sendToWebhookIfNeeded(decoderResults: decoderResults)
        resultsInSession.append(contentsOf: decoderResults)
        if let lastThumbnail = thumbnails?.last {
            thumbnailsInSession = [lastThumbnail]
        }
        showResult(decoderResults: decoderResults, thumbnails: thumbnails ?? [])
        appendResultLines(decoderResults)
    }
    
    func showResult(decoderResults: [DecoderResult], thumbnails: [UIImage], forceOpen: Bool = false) {
        guard let closeSessionOnResultEnabled = config?.closeSessionOnResultEnabled else { return }
        
        expandButton.isHidden = false
        numberOfScans.isHidden = false
        
        numberOfScans.text = "(\(resultsInSession.count))"
        
        if !forceOpen {
            switch settingsType {
            case .all:
                guard UserDefaults.standard.getAutomaticShowBottomSheet(for: "all") else {
                    return
                }
            case .batch:
                guard UserDefaults.standard.getAutomaticShowBottomSheet(for: "batch") else {
                    return
                }
            case .general:
                guard UserDefaults.standard.getAutomaticShowBottomSheet(for: "general") else {
                    return
                }
            case .template(let template):
                guard UserDefaults.standard.getAutomaticShowBottomSheet(for: String(template.rawValue)) else {
                    return
                }
            case .showcase(let showcase):
                guard UserDefaults.standard.getAutomaticShowBottomSheet(for: String(showcase.rawValue)) else {
                    return
                }
            }
        }
        
        if presentedResultDetailsViewController == nil {
            presentedResultDetailsViewController = ResultDetailsViewController(resultDetailsType: .decoderTypes(result: (resultsInSession, thumbnails)), isContinuousMode: !closeSessionOnResultEnabled)
        }
        presentedResultDetailsViewController?.modalPresentationStyle = .overFullScreen
        presentedResultDetailsViewController?.delegate = self
        if let presentedResultDetailsViewController {
            if let vc = presentedViewController as? ResultDetailsViewController {
                vc.updateWith(decoderResults: resultsInSession, thumbnails: thumbnails)
            } else {
                guard !isPresentingBottomSheetInProgress else { return }
                isPresentingBottomSheetInProgress = true
                present(presentedResultDetailsViewController, animated: false) {
                    self.isPresentingBottomSheetInProgress = false
                }
            }
        }
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.dismissScannerVC()
    }
    
    @IBAction func zoomButtonClick(_ sender: Any) {
        currentZoom = currentZoom == ScannerViewController.ZOOM_OFF_VAL
        ? ScannerViewController.ZOOM_ON_VAL
        : ScannerViewController.ZOOM_OFF_VAL
    }
    
    @IBAction func flashButtonClick(_ sender: Any) {
        isFlashActive = !isFlashActive
    }
    
    private func dismissScannerVC() {
        self.barkoderView.stopScanning()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func startScanningIfNeeded() {
        guard let closeSessionOnResultEnabled = config?.closeSessionOnResultEnabled else { return }

        if closeSessionOnResultEnabled {
            shouldShowImage = false
            try? self.barkoderView.startScanning(self)
        }
    }
    
    private func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScannerToSettingsSegue" {
            let navigationController = segue.destination as? UINavigationController
            let settingsViewController = navigationController?.viewControllers.first as? SettingsViewController
            settingsViewController?.onDoneBlock = { isConfigChanged in
                self.shouldShowImage = false
                try? self.barkoderView.startScanning(self)
                self.updateActiveSymbologiesText()
                self.adjustRoi()
                self.updateMultiScanDelayLabel()
                if isConfigChanged {
                    self.informUserAboutTheChanges()
                }
            }
            settingsViewController?.delegate = self
            settingsViewController?.config = config
            settingsViewController?.type = settingsType
            
            self.barkoderView.pauseScanning()
        }
    }
    
    fileprivate func updateActiveSymbologiesText() {
        let activeSymbologiesText = barkoderView
            .config?
            .decoderConfig?
            .getEnabledDecoders()
            .map {
                let decoderType = DecoderType(rawValue: UInt32(truncating: $0))
                return BKDUtils.getNameFor(decoderType, config: barkoderView.config)
            }
            .joined(separator: ", ")
        
        self.symbologiesLabel.text = activeSymbologiesText?.isEmpty ?? true ? "" : activeSymbologiesText
    }
    
    fileprivate func showPermissionAlert() {
        let alertController = UIAlertController(
            title: "Camera Access Restricted",
            message: "Adjust Settings for Permissions",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Open settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL)  {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

extension ScannerViewController: ResultDetailsViewControllerDelegate {
    
    func didRequestOpenSettings() {
        barkoderView.pauseScanning()
        performSegue(withIdentifier: "ScannerToSettingsSegue", sender: self)
    }
    
    func dismissedScreen() {
        presentedResultDetailsViewController = nil
    }
    
    func didTap(action: ResultDetailsAction) {
        switch action {
        case .copyValue(_):
            startScanningIfNeeded()
        case .webhook(_):
            break
        case .search(_):
            break
        case .sendCSVtoMail(_):
            startScanningIfNeeded()
        case .dismiss:
            startScanningIfNeeded()
        }
    }
    
}

private extension ScannerViewController {
    
    func sendToWebhookIfNeeded(decoderResults: [DecoderResult]) {
        if UserDefaults.standard.getSendToWebhookAutomatically() && UserDefaults.standard.getWebhookFeatureEnabled() {
            let values = decoderResults.compactMap { ($0.barcodeTypeName ?? "N/A", $0.textualData ?? "N/A") }
            WebhookService.sendWebhook(values: values) { _ in
                // Sending to webhook automatically so we don't need any feedback here
            }
        }
    }
    
}

extension ScannerViewController: BarkoderPerformanceDelegate {
    
    func performanceReceived(fps: Float, dps: Float) {
        let fpsLabelText = String(
            format: "FPS: %.1f \nDPS: %.1f",
            fps,
            dps
        )
        fpsLabel.text = fpsLabelText
    }
    
}

// MARK: - Private methods

private extension ScannerViewController {
    
    func informUserAboutTheChanges() {
        var toastMessage: String?
        
        switch settingsType {
        case .all, .general, .batch:
            toastMessage = "Settings are changed successfully!"
        case .template(let template):
            switch template {
            case .all:
                toastMessage = "Settings are changed successfully!"
            case .qr:
                toastMessage = "Settings are changed for QR Codes template!"
            case .all_2d:
                toastMessage = "Settings are changed for All 2D template!"
            case .industrial_1d:
                toastMessage = "Settings are changed for Industrial 1D template!"
            case .retail_1d:
                toastMessage = "Settings are changed for Retail 1D template!"
            case .pdf_optimized:
                toastMessage = "Settings are changed for PDF optimized template!"
            case .dpm:
                toastMessage = "Settings are changed for DPM mode!"
            case .vin:
                toastMessage = "Settings are changed for VIN mode!"
            case .dotcode:
                toastMessage = "Settings are changed for Dotcode mode!"
            @unknown default:
                break
            }
        case .showcase(let showcase):
            switch showcase {
            case .misshaped:
                toastMessage = "Settings are changed for Misshaped showcase!"
            case .deblur:
                toastMessage = "Settings are changed for Deblur showcase!"
            }
        }
        
        if let toastMessage {
            view.makeToast(toastMessage, duration: 1, position: CSToastPositionBottom)
        }
    }
    
}


extension ScannerViewController: SettingsViewControllerDelegate {
    
    func didChangeConfig(newBarkoderConfig: BarkoderSDK.BarkoderConfig) {
        config = newBarkoderConfig
        barkoderView.config = newBarkoderConfig
        updateActiveSymbologiesText()
        adjustRoi()
        updateMultiScanDelayLabel()
    }
        
}
