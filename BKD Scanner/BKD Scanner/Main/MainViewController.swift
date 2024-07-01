//
//  ViewController.swift
//  BKD Scanner
//
//  Created on 21/01/21.
//

import UIKit
import BarkoderSDK

class MainViewController: UIViewController, BarkoderResultDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let SCANNER_SEGUE_IDENTIFIER = "ScannerSegue"
    private let SCANNER_SEGUE_IDENTIFIER_FFA = "ScannerSegueFFA"
    private let SCANNER_SEGUE_IDENTIFIER_CONTINUOUS = "ScannerSegueContinuous"
    private let SETTINGS_SEGUE_IDENTIFIER = "SettingsSegue"

    var settingsType: SettingsViewController.SettingsType? = nil
    
    @IBOutlet weak var scanHolderView: UIView!
    @IBOutlet weak var ffaButton: UIButton!
    @IBOutlet weak var gridCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpCollectionView()
    }
    
    
    private var collectionViewContent: [MainCollectionSection] = []
    
    private func setupUI() {
        scanHolderView.layer.cornerRadius = scanHolderView.frame.height / 2
        
        ffaButton.layer.cornerRadius = ffaButton.frame.height / 2
        ffaButton.backgroundColor = AppColor.brand.color
    }
    
    private func setUpCollectionView() {
        collectionViewContent = [
            MainCollectionSection(title: "1D Barcodes", items: [
				MainCollectionItem(title: "All 1D", image: UIImage(named: "ico-1d-all"), action: { self.startScannerWithTemplate(template: .all_1d) }),
                MainCollectionItem(title: "1D Industrial", image: UIImage(named: "ico-1d-industrial"), action: { self.startScannerWithTemplate(template: .industrial_1d) }),
                MainCollectionItem(title: "1D Retail", image: UIImage(named: "ico-1d-retail"), action: { self.startScannerWithTemplate(template: .retail_1d) }),
            ]),
            MainCollectionSection(title: "2D Barcodes", items: [
				MainCollectionItem(title: "All 2D", image: UIImage(named: "ico-2d-all"), action: { self.startScannerWithTemplate(template: .all_2d) }),
                MainCollectionItem(title: "PDF417", image: UIImage(named: "ico-2d-pdf"), action: { self.startScannerWithTemplate(template: .pdf_optimized) }),
                MainCollectionItem(title: "DotCode", image: UIImage(named: "ico-dotcode"), action: { self.startScannerWithTemplate(template: .dotcode) })
            ]),
            MainCollectionSection(title: "Showcase", items: [
                MainCollectionItem(title: "MultiScan", image: UIImage(named: "ico-showcase-batch-multi"), action: { self.continuousScanningClicked() }),
                MainCollectionItem(title: "DPM", image: UIImage(named: "ico-showcase-dpm"), action: { self.startScannerWithTemplate(template: .dpm) }),
                MainCollectionItem(title: "VIN", image: UIImage(named: "ico-showcase-vin"), action: { self.startScannerWithTemplate(template: .vin) }),
                MainCollectionItem(title: "Deblur", image: UIImage(named: "ico-showcase-blurred"), action: { self.startScannerWith(.deblur) }),
				MainCollectionItem(title: "Misshaped", image: UIImage(named: "ico-showcase-misshaped"), action: { self.startScannerWith(.misshaped) }),
				MainCollectionItem(title: "Gallery scan", image: UIImage(named: "ico-utility-photo"), action: { self.presentImagePicker() }),
            ])
        ]
        
        gridCollectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        gridCollectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")

        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 4

        gridCollectionView.setCollectionViewLayout(layout, animated: true)
    }
        
    func startScannerWithTemplate(template: BarkoderHelper.BarkoderConfigTemplate) {
        settingsType = .template(template)

        if let data = UserDefaults.standard.getBkdConfigDataFor(template) {
            // Converting from Data from user defaults to BarkoderConfig model
            BarkoderHelper.applyConfigSettingsFromJson(ConfigManager.shared.templateConfig, jsonData: data) { localConfig, error in
                guard let config = localConfig else { return }
                
                UserDefaults.standard.saveBkdConfigFor(template, bkdConfig: config)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.SCANNER_SEGUE_IDENTIFIER, sender: config)
                }
            }
        } else {
            ConfigManager.getCofigWithTemplate(template: template) { config in
                UserDefaults.standard.saveBkdConfigFor(template, bkdConfig: config)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.SCANNER_SEGUE_IDENTIFIER, sender: config)
                }
            }
        }
    }
    
    fileprivate func startScannerWith(_ showcase: Showcase) {
        settingsType = .showcase(showcase)
        if let data = UserDefaults.standard.getBkdConfigDataFor(showcase) {
            // Converting from Data from user defaults to BarkoderConfig model
            BarkoderHelper.applyConfigSettingsFromJson(ConfigManager.shared.templateConfig, jsonData: data) { localConfig, error in
                guard let config = localConfig else { return }
                
                UserDefaults.standard.saveBkdConfigFor(showcase, bkdConfig: config)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.SCANNER_SEGUE_IDENTIFIER, sender: config)
                }
            }
        } else {
            // Misshaped and deblur showcases, are the same as retail config
            switch showcase {
            case .misshaped, .deblur:
                ConfigManager.getCofigWithTemplate(template: .retail_1d) { config in
                    var updatedConfig: BarkoderConfig? = config
                    if let updatedConfig = BKDUtils.setDefaultValuesFor(showcase, barkoderConfig: &updatedConfig) {
                        UserDefaults.standard.saveBkdConfigFor(showcase, bkdConfig: updatedConfig)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: self.SCANNER_SEGUE_IDENTIFIER, sender: config)
                        }
                    }
                }
            }
        }
    }
        
    @IBAction func ffaClicked(_ sender: Any) {
        self.performSegue(withIdentifier: SCANNER_SEGUE_IDENTIFIER_FFA, sender: ConfigManager.shared.ffaConfig)
    }
    
    func continuousScanningClicked() {
        self.performSegue(withIdentifier: self.SCANNER_SEGUE_IDENTIFIER_CONTINUOUS, sender: ConfigManager.shared.continuousConfig)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SCANNER_SEGUE_IDENTIFIER || segue.identifier == SCANNER_SEGUE_IDENTIFIER_FFA || segue.identifier == SCANNER_SEGUE_IDENTIFIER_CONTINUOUS {
            guard let scannerViewController = segue.destination as? ScannerViewController,
                  let config = sender as? BarkoderConfig
            else { return }
            
            scannerViewController.config = config
            if let settingsType = settingsType {
                scannerViewController.settingsType = settingsType
				self.settingsType = nil
			} else {
				if segue.identifier == SCANNER_SEGUE_IDENTIFIER_CONTINUOUS {
					scannerViewController.settingsType = .batch
				} else {
					scannerViewController.settingsType = .all
				}
			}
        } else if (segue.identifier == SETTINGS_SEGUE_IDENTIFIER) {
            guard let settingsViewController = segue.destination as? SettingsViewController
            else { return }
            
            settingsViewController.config = ConfigManager.shared.ffaConfig
            settingsViewController.type = .general
        }
    }
    
    // Barkoder delegate
    
    func scanningFinished(_ decoderResults: [DecoderResult], thumbnails: [UIImage]?, image: UIImage?) {
        var resultTexts: [String] = []
        for (index, result) in decoderResults.enumerated() {
            if index > 0 {
                resultTexts.append("\n")
            }
            
            let resultText = result.getParsedResultOrTextual()
            resultTexts.append("\(result.barcodeTypeName ?? "")\n" + resultText)
            CoreDataHelper.saveScanLog(value: resultText, symbology: result.barcodeTypeName)
        }

        if decoderResults.count > 0 {
            let vc = ResultDetailsViewController(resultDetailsType: .decoderTypes(result: (decoderResults, thumbnails ?? [])))
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: false)
            
        } else {
            let title = "No barcodes found"
            let alertController = UIAlertController.init(title: title, message: resultTexts.joined(separator: "\n"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Collection view delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionViewContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionViewContent[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "CollectionCell",
          for: indexPath
        ) as! MainCollectionViewCell

        let mainItemModel = collectionViewContent[indexPath.section].items[indexPath.row]
        
        cell.title.text = mainItemModel?.title
        cell.image.image = mainItemModel?.image
        cell.setUpAppearance()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
             let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
            sectionHeader.label.text = collectionViewContent[indexPath.section].title
             return sectionHeader
        } else { //No footer in this case but can add option for that
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! SectionHeader
            return sectionHeader
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 26)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == collectionViewContent.count - 1 {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainItemModel = collectionViewContent[indexPath.section].items[indexPath.row]
        mainItemModel?.action()
    }

}

// Image picker

extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func presentImagePicker() {        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        UINavigationBar.appearance().backgroundColor = .white
        UIBarButtonItem.appearance().tintColor = .black
        self.present(imagePicker, animated: true) {
            UINavigationBar.appearance().backgroundColor = .clear
            UIBarButtonItem.appearance().tintColor = .white
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            //TODO: Show error alert
            return
        }
                
        let bkdConfig = BarcodeConfigurationManager.shared.cleanConfig
        let enabledDecoders = ConfigManager.shared.ffaConfig.decoderConfig?.getEnabledDecoders() ?? []
        bkdConfig.decoderConfig?.setEnabledDecoders(enabledDecoders)
        bkdConfig.decoderConfig?.formatting = ConfigManager.shared.ffaConfig.decoderConfig?.formatting ?? .init(rawValue: 0)
        bkdConfig.decoderConfig?.decodingSpeed = ConfigManager.shared.ffaConfig.decoderConfig?.decodingSpeed ?? .init(rawValue: 1)
        BarkoderHelper.scanImage(image.fixOrientation(), bkdConfig: bkdConfig, resultDelegate: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
		let cellWidth = min(140, screenWidth / 3.5)
        return CGSize(width: cellWidth, height: cellWidth - 25)
    }
}

class SectionHeader: UICollectionReusableView {
     var label: UILabel = {
         let label: UILabel = UILabel()
         label.textColor = .black
         label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
         label.sizeToFit()
         return label
     }()

     override init(frame: CGRect) {
         super.init(frame: frame)

         addSubview(label)

         label.translatesAutoresizingMaskIntoConstraints = false
         label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
         label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
         label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MainViewController: ResultDetailsViewControllerDelegate {
    
    func didRequestOpenSettings() {
        performSegue(withIdentifier: SETTINGS_SEGUE_IDENTIFIER, sender: self)
    }
    
    
    func didTap(action: ResultDetailsAction) {
        // TODO: -
    }
    
}
