//
//  SettingsViewController.swift
//  BKD Scanner
//
//  Created on 12/03/21.
//

import UIKit
import BarkoderSDK

protocol SettingsViewControllerDelegate: AnyObject {
    func didChangeConfig(newBarkoderConfig: BarkoderConfig)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {
    
    enum SettingsType {
        case template(BarkoderHelper.BarkoderConfigTemplate)
        case showcase(Showcase)
        case all
        case general
        case batch
    }
    
    private let SECTION_HEADER_HEIGHT = CGFloat(80)
    private let SETTINGS_SEGUE_IDENTIFIER = "SettingsSegue"

    @IBOutlet weak var tableView: UITableView!
    private var doneButton: UIBarButtonItem?
    private var tableContent: [Section] {
        switch type {
        case .all, .batch:
            return viewModel?.getTableContentForAll() ?? []
        case .template(let templete):
            return viewModel?.getTableContentFor(templete: templete) ?? []
        case .general:
            return viewModel?.generalSections() ?? []
        case .showcase(let showcase):
            return viewModel?.getTableContentFor(showcase: showcase) ?? []
        }
    }
    private var viewModel: SettingsViewModel?
    
    var onDoneBlock : ((Bool) -> Void)?
    var config: BarkoderConfig? = nil
    var type: SettingsType = .all
    weak var delegate: SettingsViewControllerDelegate?
    
    /// Used for tapping custom template from general settings
    var tappedType: SettingsType?
    var isConfigChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        setupUI()
    }
    
    private func setupUI() {
        viewModel = SettingsViewModel(config: config, type: type) { [weak self] result in
            switch result {
            case .configureWebhook:
                self?.configureWebhook()
            case .reloadData(let updatedConfig):
                self?.config = updatedConfig
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.tableView.reloadData()
                }
                self?.isConfigChanged = true
            case .resetConfig:
                self?.resetConfig()
            case .none:
                break
            case .switchRowAction(let configTuple):
                self?.switchRowAction(specificConfig: configTuple.0, decoderType: configTuple.1)
                self?.isConfigChanged = true
            case .updateIndividualTemplate(let template):
                self?.openSettingsFor(template: template)
            case .updateIndividualShowcase(let showcase):
                self?.openSettingsFor(showcase: showcase)
            case .updateAnycode:
                self?.openSettingsForAnyCode()
            case .updateBatchScan:
                self?.openSettingsForBatchScan()
            case .enableWebhook:
                if let self,
                   UserDefaults.standard.getWebhookUrl() == nil,
                   UserDefaults.standard.getWebhookSecretWord() == nil {
                    GeneralUtilities.showWebhookExplanationAlert(self, openSettingsCompletion: {})
                }
            }
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.IDENTIFIER)
        tableView.register(NavigationCell.self, forCellReuseIdentifier: NavigationCell.IDENTIFIER)
        tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.IDENTIFIER)
        tableView.register(SliderCell.self, forCellReuseIdentifier: SliderCell.IDENTIFIER)
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: SubtitleCell.IDENTIFIER)

        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func updateTitle() {
        switch type {
        case .all:
            title = "Anycode"
        case .general:
            title = "Settings"
        case .batch:
            title = "Batch MultiScan"
        case .template(let template):
            switch template {
            case .all:
                title = "Settings"
            case .qr:
                title = "QR Codes"
            case .all_2d:
                title = "All 2D Codes"
            case .industrial_1d:
                title = "1D Industrial"
            case .retail_1d:
                title = "1D Retail"
            case .pdf_optimized:
                title = "PDF417"
            case .dpm:
                title = "DPM Mode"
            case .vin:
                title = "VIN mode"
            case .dotcode:
                title = "Dot code"
			case .all_1d:
				title = "All 1D Codes"
            @unknown default:
                break
            }
        case .showcase(let showcase):
            switch showcase {
            case .misshaped:
                title = "Misshaped"
            case .deblur:
                title = "Deblur"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.clearSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.clearSelection()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableContent.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableContent[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableContent[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        (cell as? Configurable)?.configure(with: row)
        (cell as? SwitchCell)?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableContent[section].name.isEmpty {
            return 0
        }
        return SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 14, y: SECTION_HEADER_HEIGHT - 30, width: self.view.frame.width, height: 20))
        label.text = tableContent[section].name
        label.textColor = #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: SECTION_HEADER_HEIGHT))
        view.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9215686275, blue: 0.9490196078, alpha: 1)
        view.addSubview(label)
        
        return view
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // SYMBOLOGIES
        if (tableContent[indexPath.section].name == (SettingsViewModel.SYMBOLOGIES_SECTION_NAME) || tableContent[indexPath.section].name == SettingsViewModel.TEMPLATES_SECTION_NAME) {
            guard let row = tableContent[indexPath.section].rows[indexPath.row] as? SwitchRow else { return }
            row.additionalSettingsAction?()
            return
        }
        
        // MULTIOPTIONS
        let row = tableContent[indexPath.section].rows[indexPath.row]
        if let navigationRow = row as? NavigationRow {
            self.performSegue(withIdentifier: "MultiOptionsSegue", sender: navigationRow)
        }
        
        // ACTIONS
        if let actionRow = row as? ActionRow {
            actionRow.action?()
        }
    }
    
    func switchCell(_ cell: SwitchCell, didToggleSwitch isOn: Bool) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let row = tableContent[indexPath.section].rows[indexPath.row] as? SwitchRow
        else {
            return
        }
        row.isOn = isOn
        cell.updateAdditionalSettingsIndicator(row: row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SettingsViewModel.SYMBOLOGIES_OPTIONS_SEGUE {
            guard
                let symbologyOptionsController = segue.destination as? SymbologyOptionsController,
                let specificConfig = sender as? SpecificConfig
            else { return }
        
            symbologyOptionsController.specificConfig = specificConfig
           
            return
        } else if (segue.identifier == SETTINGS_SEGUE_IDENTIFIER) {
            guard let settingsViewController = segue.destination as? SettingsViewController
            else { return }
            
            settingsViewController.config = config
            if let tappedType {
                settingsViewController.type = tappedType
                self.tappedType = nil
            }
            
            return
        }
        
        guard
            let navigationRow = sender as? NavigationRow,
            let multiOptionsController = segue.destination as? MultiOptionsController
        else {
            return
        }
        
        if navigationRow.title == "Continuous threshold" {
            multiOptionsController.type = .continuesScanningExplanation
        }
        multiOptionsController.navigationRow = navigationRow
    }
    
    @objc
    private func doneClicked() {
        switch type {
        case .template(let template):
            if let config = config {
                UserDefaults.standard.saveBkdConfigFor(template, bkdConfig: config)
            }
        case .showcase(let showcase):
            if let config = config {
                UserDefaults.standard.saveBkdConfigFor(showcase, bkdConfig: config)
            }
        case .batch:
            if let config {
                UserDefaults.standard.saveContinuousBkdConfig(bkdConfig: config)
            }
        case .all:
            if let config {
                UserDefaults.standard.saveBkdConfig(bkdConfig: config)
            }
        case .general:
            if let config, config == ConfigManager.shared.continuousConfig {
                UserDefaults.standard.saveContinuousBkdConfig(bkdConfig: config)
            }
        }

        if let presentingNavigationController = navigationController {
            // If the view controller is embedded in a navigation controller, pop it
            if presentingNavigationController.viewControllers.count > 1 {
                presentingNavigationController.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            // Otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onDoneBlock?(isConfigChanged)
    }
    
}

// MARK: - Helping methods

private extension SettingsViewController {
    
    func switchRowAction(specificConfig: SpecificConfig, decoderType: DecoderType) {
        if specificConfig.enabled && BKDUtils.hasAdditionalSymbologySettings(decoderType: decoderType) {
            self.performSegue(withIdentifier: SettingsViewModel.SYMBOLOGIES_OPTIONS_SEGUE, sender: specificConfig)
        } else if specificConfig.enabled && BKDUtils.hasExpandSettings(decoderType: decoderType) {
            self.performSegue(withIdentifier: SettingsViewModel.SYMBOLOGIES_OPTIONS_SEGUE, sender: specificConfig)
        }
    }
        
    func resetConfig() {
        let alert = UIAlertController(title: "Reset all settings values to defaults", message: nil, preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "Reset", style: .default) { _ in
            guard let config = self.config else { return }
            
            switch self.type {
            case .batch:
                BKDUtils.resetAndReturnBatchScanConfigFor { resetedBarkoderConfig in
                    UserDefaults.standard.saveContinuousBkdConfig(bkdConfig: resetedBarkoderConfig)
                    self.config = resetedBarkoderConfig
                    self.viewModel?.config = resetedBarkoderConfig
                    ConfigManager.shared.continuousConfig = resetedBarkoderConfig
                }
            case .all:
                BKDUtils.resetAndReturnConfigFor(oldConfig: config) { resetedBarkoderConfig in
                    UserDefaults.standard.saveBkdConfig( bkdConfig: resetedBarkoderConfig)
                    self.config = resetedBarkoderConfig
                    self.viewModel?.config = resetedBarkoderConfig
                    ConfigManager.shared.ffaConfig = resetedBarkoderConfig
                }
            case .general:
                BKDUtils.resetAllApplication()
            case .template(let template):
				
				// Resetting viewfinder's size, this settings is not from the sdk
				switch template {
				case .dpm:
					UserDefaults.standard.setDpmBiggerViewFinder(false)
				case .vin:
					UserDefaults.standard.setVinNarrowViewFinder(false)
				default:
					break
				}
				
                ConfigManager.getCofigWithTemplate(template: template) { resetedBarkoderConfig in
                    UserDefaults.standard.saveBkdConfigFor(template, bkdConfig: resetedBarkoderConfig)
                    self.config = resetedBarkoderConfig
                    self.viewModel?.config = resetedBarkoderConfig
                    self.delegate?.didChangeConfig(newBarkoderConfig: resetedBarkoderConfig)
                }
            case .showcase(let showcase):
                ConfigManager.getCofigWithTemplate(template: .retail_1d) { resetedBarkoderConfig in
					var updatedConfig: BarkoderConfig? = resetedBarkoderConfig
					if let updatedConfig = BKDUtils.setDefaultValuesFor(showcase, barkoderConfig: &updatedConfig) {
						UserDefaults.standard.saveBkdConfigFor(showcase, bkdConfig: updatedConfig)
						self.config = resetedBarkoderConfig
						self.viewModel?.config = resetedBarkoderConfig
						self.delegate?.didChangeConfig(newBarkoderConfig: resetedBarkoderConfig)
					}
                }
            }
            self.tableView.reloadData()
            self.isConfigChanged = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func configureWebhook() {
        isConfigChanged = true
        
        let vc = WebhookConfigurationAlertViewController()
        vc.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            self.present(vc, animated: false)
        }
    }
    
    /// Get config and open individual settings
    /// - Parameter template: Selected template
    func openSettingsFor(template: BarkoderHelper.BarkoderConfigTemplate) {
        self.tappedType = .template(template)

        if let data = UserDefaults.standard.getBkdConfigDataFor(template) {
            // Converting from Data from user defaults to BarkoderConfig model
            BarkoderHelper.applyConfigSettingsFromJson(ConfigManager.shared.templateConfig, jsonData: data) { localConfig, error in
                guard let config = localConfig else { return }
                
                UserDefaults.standard.saveBkdConfigFor(template, bkdConfig: config)
                self.config = localConfig
                
                self.performSegue(withIdentifier: self.SETTINGS_SEGUE_IDENTIFIER, sender: self)
            }
        } else {
            ConfigManager.getCofigWithTemplate(template: template) { config in
                UserDefaults.standard.saveBkdConfigFor(template, bkdConfig: config)
                self.config = config
                
                self.performSegue(withIdentifier: self.SETTINGS_SEGUE_IDENTIFIER, sender: self)
            }
        }
    }
    
    func openSettingsFor(showcase: Showcase) {
        self.tappedType = .showcase(showcase)
        
        if let data = UserDefaults.standard.getBkdConfigDataFor(showcase) {
            // Converting from Data from user defaults to BarkoderConfig model
            BarkoderHelper.applyConfigSettingsFromJson(ConfigManager.shared.templateConfig, jsonData: data) { localConfig, error in
                guard let config = localConfig else { return }
                
                UserDefaults.standard.saveBkdConfigFor(showcase, bkdConfig: config)
                self.config = localConfig
                
                self.performSegue(withIdentifier: self.SETTINGS_SEGUE_IDENTIFIER, sender: self)
            }
        } else {
            // Misshaped and deblur showcases, are the same as retail config
            switch showcase {
            case .misshaped, .deblur:
                ConfigManager.getCofigWithTemplate(template: .retail_1d) { config in
                    var updatedConfig: BarkoderConfig? = config
                    if let updatedConfig = BKDUtils.setDefaultValuesFor(showcase, barkoderConfig: &updatedConfig) {
                        UserDefaults.standard.saveBkdConfigFor(showcase, bkdConfig: config)
                        self.config = config
                        
                        self.performSegue(withIdentifier: self.SETTINGS_SEGUE_IDENTIFIER, sender: self)
                    }
                }
            }
        }
    }
    
    func openSettingsForAnyCode() {
        tappedType = .all
        config = ConfigManager.shared.ffaConfig
        
        performSegue(withIdentifier: SETTINGS_SEGUE_IDENTIFIER, sender: ConfigManager.shared.ffaConfig)
    }
    
    func openSettingsForBatchScan() {
        tappedType = .batch
        config = ConfigManager.shared.continuousConfig
        
        performSegue(withIdentifier: SETTINGS_SEGUE_IDENTIFIER, sender: ConfigManager.shared.continuousConfig)
    }
    
}
