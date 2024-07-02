//
//  AboutViewController.swift
//  BKD Scanner
//
//  Created on 09/03/21.
//

import UIKit
import Barkoder

class AboutViewController: UIViewController {

    private var titleLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var testBarkoderButton: UIButton!
    @IBOutlet weak var changelogStackView: UIStackView!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!
    private var isDeveloperModeEnabled: Bool = false {
        didSet {
            let sdkVersion = iBarkoder.GetVersion()
            
            var targetName: String = ""
            #if BARKODER
            targetName = "Barkoder"
            #elseif SCAN
            targetName = "Scan"
            #endif
            
            titleLabel.text = isDeveloperModeEnabled
            ? "\(targetName) SDK version \(sdkVersion)" + "\n\(targetName) lib version \(iBarkoder.getLibVersion() ?? "")"
            : "\(targetName) SDK version \(sdkVersion)"
            changelogStackView.layoutIfNeeded()
        }
    }
        
    private var changelogItems: [ChangelogItem] {
        let bundle = Bundle(for: Self.self)
        #if BARKODER
        let url = bundle.url(forResource: "barkoder-changelog.json", withExtension: nil)
        #elseif SCAN
        let url = bundle.url(forResource: "scan-changelog.json", withExtension: nil)
        #endif
        var changelogItems = [ChangelogItem]()
        
        guard let jsonFile = url else { return changelogItems }
        
        let jsonDecoder = JSONDecoder()
        do {
            let jsonData = try Data(contentsOf: jsonFile)
            changelogItems = try jsonDecoder.decode([ChangelogItem].self, from: jsonData)
        } catch {
            print("Failed to build json: \(error)")
        }
        
        return changelogItems
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        versionLabel.text = "Version \(appVersion)"
        
        changelogStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        changelogStackView.isLayoutMarginsRelativeArrangement = true

        var targetName: String = ""
        #if BARKODER
        targetName = "barKoder"
        #elseif SCAN
        targetName = "Scan"
        #endif

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = "\(targetName) SDK version \(iBarkoder.GetVersion())"
        titleLabel.numberOfLines = 2
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Changelog"
        
        deviceIdLabel.font = .systemFont(ofSize: 15, weight: .bold)
        deviceIdLabel.numberOfLines = 2
        deviceIdLabel.textAlignment = .center
        deviceIdLabel.text = String(
            format: "Device id: %@",
            ConfigManager.shared.ffaConfig.decoderConfig?.getDeviceId() ?? "N/A"
        )
        
        changelogStackView.addArrangedSubview(titleLabel)
        changelogStackView.addArrangedSubview(subtitleLabel)

        for changelogItem in changelogItems {
            let versionLabel = UILabel()
            versionLabel.text = "\(changelogItem.version)"
            versionLabel.font = .systemFont(ofSize: 15, weight: .bold)
            
            let changesText = changelogItem.changes.joined(separator: "\n")
            
            let changesLabel = UILabel()
            changesLabel.text = "\(changesText)"
            changesLabel.font = .systemFont(ofSize: 15, weight: .regular)
            changesLabel.numberOfLines = 0
                        
            changelogStackView.addArrangedSubview(versionLabel)
            changelogStackView.addArrangedSubview(changesLabel)
        }
        
        setupUI()
    }
            
    private func setupUI() {
        let rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "questionmark"),
            style: .done,
            target: self,
            action: #selector(howToButtonTapped)
        )

        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        testBarkoderButton.layer.cornerRadius = 20
        
        changelogStackView.layer.cornerRadius = 20
        
        learnMoreButton.layer.borderWidth = 2
        learnMoreButton.layer.cornerRadius = 20
        learnMoreButton.layer.borderColor = AppColor.brand.color.cgColor
        learnMoreButton.titleLabel?.numberOfLines = 1
        learnMoreButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(learnMoreLongPressed(sender:))))
        
        privacyPolicyButton.layer.borderWidth = 2
        privacyPolicyButton.layer.cornerRadius = 20
        privacyPolicyButton.layer.borderColor = AppColor.brand.color.cgColor
        
        termsOfUseButton.layer.borderWidth = 2
        termsOfUseButton.layer.cornerRadius = 20
        termsOfUseButton.layer.borderColor = AppColor.brand.color.cgColor
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(termsOfUseLongPressed(sender:))
        )
        longPressRecognizer.minimumPressDuration = 3
        termsOfUseButton.addGestureRecognizer(longPressRecognizer)
        
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func howToButtonTapped() {
        if let url = URL(string: AppConfig.howToUseLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func learnMoreTapped(_ sender: Any) {
        if let url = URL(string: AppConfig.learnMoreLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        if let url = URL(string: AppConfig.privacyPolicyLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func termsOfUseTapped(_ sender: Any) {
        if let url = URL(string: AppConfig.termsOfUseLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func testBarkoderButtonTapped(_ sender: Any) {
        if let url = URL(string: AppConfig.testBarcodeLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc
    private func learnMoreLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            isDeveloperModeEnabled.toggle()
        }
    }
    
    @objc
    private func termsOfUseLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let enabled = UserDefaults.standard.getFpsFeatureEnabled()
            UserDefaults.standard.setFpsFeatureEnabled(!enabled)
        }
    }
    
}
