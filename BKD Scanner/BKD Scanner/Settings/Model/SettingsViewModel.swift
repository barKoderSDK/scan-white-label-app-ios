//
//  SettingsViewModel.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 17.11.23.
//

import Foundation
import BarkoderSDK

final class SettingsViewModel {
    
    enum SettingsAction {
        case reloadData(BarkoderConfig?)
        case resetConfig
        case configureWebhook
        case switchRowAction((SpecificConfig, DecoderType))
        case updateIndividualTemplate(BarkoderHelper.BarkoderConfigTemplate)
        case updateIndividualShowcase(Showcase)
        case updateBatchScan
        case updateAnycode
        case enableWebhook
    }
    
    static let SYMBOLOGIES_SECTION_NAME = "Barcode Types (Scan Mode)"
    static let TEMPLATES_SECTION_NAME = "Barcode Types"
    static let SYMBOLOGIES_OPTIONS_SEGUE = "SymbologyOptionsSegue"
    static let GENERAL_SECTION_NAME = "General settings"
    static let WEBHOOK_SECTION_NAME = "Webhook settings"
    static let BARKODER_SETTINGS = "barKoder Settings"
    static let INDIVIDUAL_SETTINGS = "Scanning Modes Settings"
    
    typealias Callback = (SettingsAction?) -> Void
    
    var config: BarkoderConfig?
    var type: SettingsViewController.SettingsType
    var callback: Callback?
    
    init(
        config: BarkoderConfig?,
        type: SettingsViewController.SettingsType,
        callback: Callback?
    ) {
        self.config = config
        self.type = type
        self.callback = callback
    }
    
    func getTableContentForAll() -> [Section] {
        var content = [Section]()
        
        // Scanner settings section
        let scannerSettingsSection = Section(name: SettingsViewModel.BARKODER_SETTINGS)
        
        scannerSettingsSection.rows.append(NavigationRow(title: "Decoding Speed", selectedOptionIndex: Int(config?.decoderConfig?.decodingSpeed.rawValue ?? 1), options: ["Fast", "Normal", "Slow"], onIndexChange: { (newIndex) in
            self.config?.decoderConfig?.decodingSpeed = DecodingSpeed(rawValue: UInt32(newIndex))
            self.callback?(.reloadData(self.config))
        }))
        
        scannerSettingsSection.rows.append(NavigationRow(title: "barKoder Resolution", selectedOptionIndex: config?.barkoderResolution.rawValue ?? 0, options: ["HD", "Full HD"], onIndexChange: { (newIndex) in
            self.config?.barkoderResolution = BarkoderView.BarkoderResolution(rawValue: newIndex) ?? .normal
            self.callback?(.reloadData(self.config))
        }))
        
        if config != ConfigManager.shared.continuousConfig {
            // Hide "Close session on result" for continuous scanning
            scannerSettingsSection.rows.append(SwitchRow(title: "Continuous Scanning", isOn: !(config?.closeSessionOnResultEnabled ?? false), hasAdditionalSettings: false, onSwitch: { (isOn) in
                
                self.config?.closeSessionOnResultEnabled = !isOn
                
                self.config?.setMulticodeCachingEnabled(false)
                self.config?.decoderConfig?.duplicatesDelayMs = 0
                self.config?.decoderConfig?.maximumResultsCount = isOn ? 200 : 1
                                
                self.callback?(.reloadData(self.config))
            }))
        }
        
        if let row = generateContinousThresholdRowIfNeeded() {
            scannerSettingsSection.rows.append(row)
        }
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Enable location in preview", isOn: config?.locationInPreviewEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.locationInPreviewEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        scannerSettingsSection.rows.append(SwitchRow(title: "Allow pinch to zoom", isOn: config?.pinchToZoomEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.pinchToZoomEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Enable region of interest", isOn: config?.regionOfInterestVisible ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.regionOfInterestVisible = isOn
            self.callback?(.reloadData(self.config))
        }))
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Beep on success", isOn: config?.beepOnSuccessEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.beepOnSuccessEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        scannerSettingsSection.rows.append(SwitchRow(title: "Vibrate on success", isOn: config?.vibrateOnSuccessEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.vibrateOnSuccessEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        if let enableMisshaped1D = config?.decoderConfig?.enableMisshaped1D {
            scannerSettingsSection.rows.append(SwitchRow(title: "Scan Deformed Codes - Segment Decoding", isOn: enableMisshaped1D, hasAdditionalSettings: false, onSwitch: { (isOn) in
                self.config?.decoderConfig?.enableMisshaped1D = isOn
                self.callback?(.reloadData(self.config))
            }))
        }
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Scan blurred UPC/EAN", isOn: config?.decoderConfig?.upcEanDeblur ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.decoderConfig?.upcEanDeblur = isOn
            self.callback?(.reloadData(self.config))
        }))
        
        content.append(scannerSettingsSection)
        
        // Symbologies section
        let symbologiesSection = Section(name: SettingsViewModel.SYMBOLOGIES_SECTION_NAME)
        
        symbologiesSection.rows.append(SubtitleRow(title: "  2D Barcodes"))
        
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Aztec))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: AztecCompact))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: QR))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: QRMicro))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: PDF417))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: PDF417Micro))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datamatrix))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Dotcode))
        
        symbologiesSection.rows.append(SubtitleRow(title: "  1D Barcodes"))
        
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code128))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code93))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code39))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Codabar))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code11))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Msi))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcA))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE1))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean13))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean8))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code25))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Interleaved25))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: ITF14))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: IATA25))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Matrix25))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datalogic25))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: COOP25))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code32))
        symbologiesSection.rows.append(createSwitchRowWith(decoderType: Telepen))
        
        content.append(symbologiesSection)
        
        // Result section
        let resultSection = Section(name: "Result")
        
        resultSection.rows.append(NavigationRow(title: "Formatting Type", selectedOptionIndex: Int(config?.decoderConfig?.formatting.rawValue ?? Disabled.rawValue), options: ["Disabled", "Automatic", "GS1", "AAMVA"], onIndexChange: { (newIndex) in
            self.config?.decoderConfig?.formatting = Formatting(rawValue: UInt32(newIndex))
            self.callback?(.reloadData(self.config))
        }))
        
        resultSection.rows.append(NavigationRow(title: "Charset", selectedOptionIndex: BKDUtils.CharsetOptions.selectedCharsetIndex(charsetValue: config?.decoderConfig?.encodingCharacterSet ?? ""), options: BKDUtils.CharsetOptions.allCases.map({ return $0.displayValue }), onIndexChange: { (newIndex) in
            self.config?.decoderConfig?.encodingCharacterSet = BKDUtils.CharsetOptions.allCases[newIndex].rawValue
            self.callback?(.reloadData(self.config))
        }))
        
        content.append(resultSection)
        
        let generalSection = Section(name: SettingsViewModel.GENERAL_SECTION_NAME)
        let resetRow = ActionRow(title: "Reset config", detailText: "") {
            self.callback?(.resetConfig)
        }
        generalSection.rows.append(resetRow)
        
        let mode = ConfigManager.shared.continuousConfig == config ? "batch" : "all"
        
        let automaticShowBottomSheet = SwitchRow(
            title: "Automatically show bottomsheet",
            isOn: UserDefaults.standard.getAutomaticShowBottomSheet(for: mode),
            hasAdditionalSettings: false) { newValue in
                UserDefaults.standard.setAutomaticShowBottomSheet(newValue, for: mode)
            }
    
        generalSection.rows.append(automaticShowBottomSheet)

        content.append(generalSection)

        return content
    }
    
    func getTableContentFor(templete: BarkoderHelper.BarkoderConfigTemplate) -> [Section] {
        var content = [Section]()
        
        // MARK: - Barkoder settings

        switch templete {
		case .retail_1d, .industrial_1d, .pdf_optimized, .qr, .all_2d, .dpm, .vin, .dotcode, .all_1d:
            let scannerSettingsSection = Section(name: SettingsViewModel.BARKODER_SETTINGS)

            scannerSettingsSection.rows.append(NavigationRow(title: "Decoding Speed", selectedOptionIndex: Int(config?.decoderConfig?.decodingSpeed.rawValue ?? 1), options: ["Fast", "Normal", "Slow"], onIndexChange: { (newIndex) in
                self.config?.decoderConfig?.decodingSpeed = DecodingSpeed(rawValue: UInt32(newIndex))
                self.callback?(.reloadData(self.config))
            }))

            scannerSettingsSection.rows.append(NavigationRow(title: "barKoder Resolution", selectedOptionIndex: config?.barkoderResolution.rawValue ?? 0, options: ["HD", "Full HD"], onIndexChange: { (newIndex) in
                self.config?.barkoderResolution = BarkoderView.BarkoderResolution(rawValue: newIndex) ?? .normal
                self.callback?(.reloadData(self.config))
            }))
            
            scannerSettingsSection.rows.append(SwitchRow(title: "Continuous Scanning", isOn: !(config?.closeSessionOnResultEnabled ?? false), hasAdditionalSettings: false, onSwitch: { (isOn) in
                
                self.config?.closeSessionOnResultEnabled = !isOn
                self.config?.setMulticodeCachingEnabled(false)
                self.config?.decoderConfig?.duplicatesDelayMs = 0
                self.config?.decoderConfig?.maximumResultsCount = isOn ? 200 : 1

                self.callback?(.reloadData(self.config))
            }))
            
            if let row = generateContinousThresholdRowIfNeeded() {
                scannerSettingsSection.rows.append(row)
            }
            
            scannerSettingsSection.rows.append(SwitchRow(title: "Allow pinch to zoom", isOn: config?.pinchToZoomEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
                self.config?.pinchToZoomEnabled = isOn
                self.callback?(.reloadData(self.config))
            }))
            
            scannerSettingsSection.rows.append(SwitchRow(title: "Beep on success", isOn: config?.beepOnSuccessEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
                self.config?.beepOnSuccessEnabled = isOn
                self.callback?(.reloadData(self.config))
            }))
            scannerSettingsSection.rows.append(SwitchRow(title: "Vibrate on success", isOn: config?.vibrateOnSuccessEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
                self.config?.vibrateOnSuccessEnabled = isOn
                self.callback?(.reloadData(self.config))
            }))
            
            // Additional settings
            
            if templete == .retail_1d {
                scannerSettingsSection.rows.append(SwitchRow(
                    title: "Scan blurred UPC/EAN",
                    isOn: (config?.decoderConfig?.upcEanDeblur ?? false),
                    hasAdditionalSettings: false, onSwitch: { (isOn) in
                    self.config?.decoderConfig?.upcEanDeblur = isOn
                        self.callback?(.reloadData(self.config))
                }))
            }
            
            
            if templete == .dpm {
                scannerSettingsSection.rows.append(SwitchRow(title: "Bigger Viewfinder", isOn: UserDefaults.standard.getDpmBiggerViewFinder(), hasAdditionalSettings: false, onSwitch: { (isOn) in
                    UserDefaults.standard.setDpmBiggerViewFinder(isOn)
                }))
            } else if templete == .vin {
                scannerSettingsSection.rows.append(SwitchRow(title: "Narrow Viewfinder", isOn: UserDefaults.standard.getVinNarrowViewFinder(), hasAdditionalSettings: false, onSwitch: { (isOn) in
                    UserDefaults.standard.setVinNarrowViewFinder(isOn)
                }))
            }
            
			if templete == .retail_1d || templete == .industrial_1d || templete == .vin || templete == .all_1d {
                if let enableMisshaped1D = config?.decoderConfig?.enableMisshaped1D {
                    scannerSettingsSection.rows.append(SwitchRow(title: "Scan Deformed Codes - Segment Decoding", isOn: enableMisshaped1D, hasAdditionalSettings: false, onSwitch: { (isOn) in
                        self.config?.decoderConfig?.enableMisshaped1D = isOn
                        self.callback?(.reloadData(self.config))
                    }))
                }
            }
            
            content.append(scannerSettingsSection)
        default:
            break
        }
        
        // MARK: - Symbologies Section

        let symbologiesSection = Section(name: SettingsViewModel.TEMPLATES_SECTION_NAME)
        
        switch templete {
        case .all_2d:
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Aztec))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: AztecCompact))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: QR))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: QRMicro))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: PDF417))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: PDF417Micro))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datamatrix))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Dotcode))
            
            content.append(symbologiesSection)
        case .qr:
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: QR))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: QRMicro))
            
            content.append(symbologiesSection)
        case .pdf_optimized:
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: PDF417))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: PDF417Micro))
            
            content.append(symbologiesSection)
        case .retail_1d:
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code128))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcA))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE1))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean13))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean8))
            
            content.append(symbologiesSection)
        case .industrial_1d:
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code128))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code93))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code39))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Codabar))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code11))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Msi))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code32))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Interleaved25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: ITF14))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: IATA25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Matrix25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datalogic25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: COOP25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Telepen))
            
            content.append(symbologiesSection)
        case .dpm:
            break
        case .vin:
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code39))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code128))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datamatrix))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: QR))

            content.append(symbologiesSection)
        case .dotcode:
            break
		case .all_1d:
			// Industrial
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code128))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code93))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code39))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code25))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Codabar))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code11))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Msi))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code32))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Interleaved25))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: ITF14))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: IATA25))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Matrix25))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datalogic25))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: COOP25))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Telepen))

			// Retail
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcA))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE1))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean13))
			symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean8))
			
			content.append(symbologiesSection)
        case .all:
            return getTableContentForAll()
        @unknown default:
            return getTableContentForAll()
        }
        
        // MARK: - Result section
        
        switch templete {
        case .vin:
            break
        default:
            let resultSection = Section(name: "Result")
            
            resultSection.rows.append(NavigationRow(title: "Formatting Type", selectedOptionIndex: Int(config?.decoderConfig?.formatting.rawValue ?? Disabled.rawValue), options: ["Disabled", "Automatic", "GS1", "AAMVA"], onIndexChange: { (newIndex) in
                self.config?.decoderConfig?.formatting = Formatting(rawValue: UInt32(newIndex))
                self.callback?(.reloadData(self.config))
            }))
            
            resultSection.rows.append(NavigationRow(title: "Charset", selectedOptionIndex: BKDUtils.CharsetOptions.selectedCharsetIndex(charsetValue: config?.decoderConfig?.encodingCharacterSet ?? ""), options: BKDUtils.CharsetOptions.allCases.map({ return $0.displayValue }), onIndexChange: { (newIndex) in
                self.config?.decoderConfig?.encodingCharacterSet = BKDUtils.CharsetOptions.allCases[newIndex].rawValue
                self.callback?(.reloadData(self.config))
            }))
            
            content.append(resultSection)
        }

        // General for templates
        
        let generalSection = Section(name: SettingsViewModel.GENERAL_SECTION_NAME)
        
        let resetRow = ActionRow(title: "Reset config", detailText: "") {
            self.callback?(.resetConfig)
        }
        generalSection.rows.append(resetRow)

        let automaticShowBottomSheet = SwitchRow(
            title: "Automatically show bottomsheet",
            isOn: UserDefaults.standard.getAutomaticShowBottomSheet(for: String(templete.rawValue)),
            hasAdditionalSettings: false) { newValue in
                UserDefaults.standard.setAutomaticShowBottomSheet(newValue, for: String(templete.rawValue))
            }
        generalSection.rows.append(automaticShowBottomSheet)

        content.append(generalSection)

        return content
    }
    
    func getTableContentFor(showcase: Showcase) -> [Section] {
        var content = [Section]()

        let scannerSettingsSection = Section(name: SettingsViewModel.BARKODER_SETTINGS)
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Continuous Scanning", isOn: !(config?.closeSessionOnResultEnabled ?? false), hasAdditionalSettings: false, onSwitch: { (isOn) in
            
            self.config?.closeSessionOnResultEnabled = !isOn
            self.config?.setMulticodeCachingEnabled(false)
            self.config?.decoderConfig?.duplicatesDelayMs = 0
            self.config?.decoderConfig?.maximumResultsCount = isOn ? 200 : 1

            self.callback?(.reloadData(self.config))
        }))
        
        if let row = generateContinousThresholdRowIfNeeded() {
            scannerSettingsSection.rows.append(row)
        }
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Allow pinch to zoom", isOn: config?.pinchToZoomEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.pinchToZoomEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        
        scannerSettingsSection.rows.append(SwitchRow(title: "Beep on success", isOn: config?.beepOnSuccessEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.beepOnSuccessEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        scannerSettingsSection.rows.append(SwitchRow(title: "Vibrate on success", isOn: config?.vibrateOnSuccessEnabled ?? false, hasAdditionalSettings: false, onSwitch: { (isOn) in
            self.config?.vibrateOnSuccessEnabled = isOn
            self.callback?(.reloadData(self.config))
        }))
        
        content.append(scannerSettingsSection)
        
        switch showcase {
        case .misshaped:
            // Symbologies
            let symbologiesSection = Section(name: SettingsViewModel.SYMBOLOGIES_SECTION_NAME)

            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code128))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code93))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code39))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Codabar))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code11))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Msi))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Interleaved25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: ITF14))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: IATA25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Matrix25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Datalogic25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: COOP25))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Code32))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Telepen))

            content.append(symbologiesSection)
        case .deblur:
            // Symbologies
            let symbologiesSection = Section(name: SettingsViewModel.SYMBOLOGIES_SECTION_NAME)

            symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcA))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: UpcE1))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean13))
            symbologiesSection.rows.append(createSwitchRowWith(decoderType: Ean8))

            content.append(symbologiesSection)
        }
        
        // Result section
        let resultSection = Section(name: "Result")
        
        resultSection.rows.append(NavigationRow(title: "Formatting Type", selectedOptionIndex: Int(config?.decoderConfig?.formatting.rawValue ?? Disabled.rawValue), options: ["Disabled", "Automatic", "GS1", "AAMVA"], onIndexChange: { (newIndex) in
            self.config?.decoderConfig?.formatting = Formatting(rawValue: UInt32(newIndex))
            self.callback?(.reloadData(self.config))
        }))
        
        resultSection.rows.append(NavigationRow(title: "Charset", selectedOptionIndex: BKDUtils.CharsetOptions.selectedCharsetIndex(charsetValue: config?.decoderConfig?.encodingCharacterSet ?? ""), options: BKDUtils.CharsetOptions.allCases.map({ return $0.displayValue }), onIndexChange: { (newIndex) in
            self.config?.decoderConfig?.encodingCharacterSet = BKDUtils.CharsetOptions.allCases[newIndex].rawValue
            self.callback?(.reloadData(self.config))
        }))
        
        content.append(resultSection)
        
        // General for templates
        let generalSection = Section(name: SettingsViewModel.GENERAL_SECTION_NAME)
        
        let resetRow = ActionRow(title: "Reset config", detailText: "") {
            self.callback?(.resetConfig)
        }
        generalSection.rows.append(resetRow)

        let automaticShowBottomSheet = SwitchRow(
            title: "Automatically show bottomsheet",
            isOn: UserDefaults.standard.getAutomaticShowBottomSheet(for: String(showcase.rawValue)),
            hasAdditionalSettings: false) { newValue in
                UserDefaults.standard.setAutomaticShowBottomSheet(newValue, for: String(showcase.rawValue))
            }
        generalSection.rows.append(automaticShowBottomSheet)

        content.append(generalSection)
        
        return content
    }
    
    func generalSections() -> [Section] {
        var content = [Section]()
                
        let webhookSection = Section(name: SettingsViewModel.WEBHOOK_SECTION_NAME)
        
        let enablingWebhook = SwitchRow(
            title: "Enable webhook",
            isOn: UserDefaults.standard.getWebhookFeatureEnabled(),
            hasAdditionalSettings: false) { newValue in
                UserDefaults.standard.setWebhookFeatureEnabled(newValue)
                if newValue {
                    self.callback?(.enableWebhook)
                }
                self.callback?(.reloadData(self.config))
            }
        webhookSection.rows.append(enablingWebhook)

        let webhookRow = ActionRow(
            title: "Webhook configuration",
            detailText: "",
            isCellClickable: UserDefaults.standard.getWebhookFeatureEnabled()
        ) {
                self.callback?(.configureWebhook)
            }
        webhookSection.rows.append(webhookRow)
        
        let autoSendToWebhook = SwitchRow(
            title: "Auto send to webhook",
            isOn: UserDefaults.standard.getSendToWebhookAutomatically(),
            hasAdditionalSettings: false,
            isCellClickable: UserDefaults.standard.getWebhookFeatureEnabled()
        ) { newValue in
            UserDefaults.standard.setSendToWebhookAutomatically(newValue)
            self.callback?(.reloadData(self.config))
        }
        webhookSection.rows.append(autoSendToWebhook)
        
        let webHookConfirmationSwitchRow = SwitchRow(
            title: "Webhook Confirmation Feedback",
            isOn: UserDefaults.standard.getWebhookConfirmationFeedback(),
            hasAdditionalSettings: false,
            isCellClickable: UserDefaults.standard.getWebhookFeatureEnabled()
        ) { newValue in
                UserDefaults.standard.setWebhookConfirmationFeedback(newValue)
                self.callback?(.reloadData(self.config))
            }
        
        webhookSection.rows.append(webHookConfirmationSwitchRow)
        
        let encodeValueSwitchRow = SwitchRow(
            title: "Еncode webhook data",
            isOn: UserDefaults.standard.getWebhookEnableEncode(),
            hasAdditionalSettings: false,
            isCellClickable: UserDefaults.standard.getWebhookFeatureEnabled()
        ) { newValue in
                UserDefaults.standard.setWebhookEnableEncode(newValue)
                self.callback?(.reloadData(self.config))
            }
        webhookSection.rows.append(encodeValueSwitchRow)
        
        content.append(webhookSection)
        
        let generalSection = Section(name: SettingsViewModel.GENERAL_SECTION_NAME)
        
        let allSearchEngine = SearchEngine.allCases.compactMap { $0.title }
        var selectedIndex = 0
        
        SearchEngine.allCases.enumerated().forEach { searchEngine in
            if UserDefaults.standard.getDefaultSearchEngine() == searchEngine.element.rawValue {
                selectedIndex = searchEngine.offset
            }
        }
        
        let enablingSearch = SwitchRow(
            title: "Enable search",
            isOn: UserDefaults.standard.getSearchFeatureEnabled(),
            hasAdditionalSettings: false) { newValue in
                UserDefaults.standard.setSearchFeatureEnabled(newValue)
                self.callback?(.reloadData(self.config))
            }
        generalSection.rows.append(enablingSearch)

        let searchEngineRow = NavigationRow(
            title: "Default search engine",
            isCellClickable: UserDefaults.standard.getSearchFeatureEnabled(),
            selectedOptionIndex: selectedIndex,
            options: allSearchEngine
        ) { newIndex in
            UserDefaults.standard.setDefaultSearchEngine(searchEngine: SearchEngine.allCases[newIndex])
            self.callback?(.reloadData(self.config))
        }
        
        generalSection.rows.append(searchEngineRow)
        
        let resetRow = ActionRow(title: "Reset All Settings", detailText: "", titleColor: .red) {
            self.callback?(.resetConfig)
        }
        generalSection.rows.append(resetRow)
                
        content.append(generalSection)
        
        // Section about setting individual settings from the templates
        let individualSection = Section(name: SettingsViewModel.INDIVIDUAL_SETTINGS)
        
        let anyCodeRow = ActionRow(title: "Anycode", detailText: "") {
            self.callback?(.updateAnycode)
        }
        
        let industrialRow = ActionRow(title: "1D Industrial", detailText: "") {
            self.callback?(.updateIndividualTemplate(.industrial_1d))
        }
        
        let retailRow = ActionRow(title: "1D Retail", detailText: "") {
            self.callback?(.updateIndividualTemplate(.retail_1d))
        }
        
        let pdfRow = ActionRow(title: "PDF417", detailText: "") {
            self.callback?(.updateIndividualTemplate(.pdf_optimized))
        }
        
        let qrCodesRow = ActionRow(title: "QR Codes", detailText: "") {
            self.callback?(.updateIndividualTemplate(.qr))
        }
        
        let all2DRow = ActionRow(title: "All 2D Codes", detailText: "") {
            self.callback?(.updateIndividualTemplate(.all_2d))
        }
        
        let batchMultiScanRow = ActionRow(title: "Batch MultiScan", detailText: "") {
            self.callback?(.updateBatchScan)
        }
        
        
        let dpmModeRow = ActionRow(title: "DPM Mode", detailText: "") {
            self.callback?(.updateIndividualTemplate(.dpm))
        }
        
        let vinModeRow = ActionRow(title: "VIN Mode", detailText: "") {
            self.callback?(.updateIndividualTemplate(.vin))
        }
        
        let dotCodeRow = ActionRow(title: "DotCode", detailText: "") {
            self.callback?(.updateIndividualTemplate(.dotcode))
        }
        
        let deblurRow = ActionRow(title: "Deblur", detailText: "") {
            self.callback?(.updateIndividualShowcase(.deblur))
        }
        
        let misshapedRow = ActionRow(title: "Misshaped", detailText: "") {
            self.callback?(.updateIndividualShowcase(.misshaped))
        }
		
		let all1DRow = ActionRow(title: "All 1D Codes", detailText: "") {
			self.callback?(.updateIndividualTemplate(.all_1d))
		}
        
        individualSection.rows.append(contentsOf:
            [
				all1DRow,
                industrialRow,
                retailRow,
                pdfRow,
                all2DRow,
                batchMultiScanRow,
                dpmModeRow,
                vinModeRow,
                dotCodeRow,
                deblurRow,
                misshapedRow,
                anyCodeRow
            ]
        )
        
        content.append(individualSection)
        
        return content
    }
    
    private func createSwitchRowWith(decoderType: DecoderType) -> SwitchRow {
        let specificConfig = config?.decoderConfig?.getFor(decoderType)
        let hasAdditionalSettings = BKDUtils.hasAdditionalSymbologySettings(decoderType: decoderType)
        let hasExpandSettings = BKDUtils.hasExpandSettings(decoderType: decoderType)
        
        let title: String = BKDUtils.getNameFor(decoderType, config: config)

        return SwitchRow(
            title: title,
            isOn: specificConfig?.enabled ?? false,
            hasAdditionalSettings: hasAdditionalSettings || hasExpandSettings,
            isCellClickable: true,
            onSwitch: { (isOn) in
                specificConfig?.enabled = isOn
                self.callback?(.reloadData(self.config))
            })
        {
            guard let specificConfig = specificConfig else { return }
            
            self.callback?(.switchRowAction((specificConfig, decoderType)))
        }
    }
    
    private func generateContinousThresholdRowIfNeeded() -> NavigationRow? {
        if let thresholdBetweenDuplicatesScans = config?.thresholdBetweenDuplicatesScans,
           config?.closeSessionOnResultEnabled == false
        {
            let options = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Unlimited"]
            let additionalSettings = [String]()
            let selectedOptionIndex = options.firstIndex(where: { $0 == String(thresholdBetweenDuplicatesScans)})
            
            let index = selectedOptionIndex ?? options.count - 1
            
            let row = NavigationRow(
                title: "Continuous threshold",
                selectedOptionIndex: index,
                options: options,
                additionalOptions: additionalSettings,
                onIndexChange: { (newIndex) in
                    let newValue = options[newIndex]
                    if let intValue = Int(newValue) {
                        self.config?.thresholdBetweenDuplicatesScans = intValue
                        self.config?.decoderConfig?.duplicatesDelayMs = Int32(intValue)
                    } else {
                        self.config?.thresholdBetweenDuplicatesScans = -1
                        self.config?.decoderConfig?.duplicatesDelayMs = 0
                    }
                    
                    self.callback?(.reloadData(self.config))
                })
            
            return row
        } else {
            return nil
        }
    }
        
}
