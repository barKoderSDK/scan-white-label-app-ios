//
//  BKDUtils.swift
//  BKD Scanner
//
//  Created on 07/01/22.
//

import Foundation
import Barkoder
import BarkoderSDK

class BKDUtils {
    
    private static let symbologiesWithAdditionalSettings = [Code128, Code93, Code39, Codabar, Code11, Msi, Code25, Interleaved25, IATA25, Matrix25, Datalogic25, COOP25, Code32, Telepen]
    private static let symbologiesWithChecksumSettings = [Code39, Code11, Msi, Code25, Interleaved25, IATA25, Matrix25, Datalogic25, COOP25]
    private static let symbologiesWithExpandSettings = [UpcE, UpcE1]
    
    static func hasAdditionalSymbologySettings(decoderType: DecoderType) -> Bool {
        return symbologiesWithAdditionalSettings.contains(decoderType)
    }
    
    static func hasCheckSum(decoderType: DecoderType) -> Bool {
        return symbologiesWithChecksumSettings.contains(decoderType)
    }
    
    static func hasExpandSettings(decoderType: DecoderType) -> Bool {
        return symbologiesWithExpandSettings.contains(decoderType)
    }
    
    enum CharsetOptions: String, CaseIterable {
        case notSet = "Not set"
        case iso88591 = "ISO-8859-1"
        case iso88592 = "ISO-8859-2"
        case iso88595 = "ISO-8859-5"
        case shiftJis = "Shift_JIS"
        case usAscii = "US-ASCII"
        case utf8 = "UTF-8"
        case utf16 = "UTF-16"
        case utf32 = "UTF-32"
        case windows1251 = "windows-1251"
        case windows1256 = "windows-1256"
        
        var displayValue: String {
            switch self {
            case .notSet: return  "Not set"
            default: return rawValue
            }
        }
        
        static func selectedCharsetIndex(charsetValue: String) -> Int {
            if charsetValue.isEmpty {
                return allCases.firstIndex(of: .notSet)!
            } else {
                if let charsetOption = CharsetOptions(rawValue: charsetValue) {
                    return allCases.firstIndex(of: charsetOption) ?? 0
                }
                
                return 0
            }
        }
    }
    
    static func resetAndReturnConfigFor(oldConfig: BarkoderConfig, completion: @escaping (BarkoderConfig) -> Void) {
        ConfigManager.copyConfig { config in
            config.decoderConfig?.getAvailableDecoders().forEach {
                let decoderType = DecoderType(rawValue: UInt32(truncating: $0))
                
                if let specificConfig = config.decoderConfig?.getFor(decoderType) as? SpecificConfig {
                    // Enabled
                    specificConfig.enabled = UserDefaults.standard.bool(forKey: "\(decoderType.rawValue)_enabled")
                    
                    // Lenghts
                    if let minimumLenght = UserDefaults.standard.object(forKey: "\(decoderType.rawValue)_minimumLength") as? Int,
                       let maximumLength = UserDefaults.standard.object(forKey: "\(decoderType.rawValue)_maximumLength") as? Int {
                        specificConfig.setLengthRangeWithMinimum(Int32(minimumLenght), maximum: Int32(maximumLength))
                    }
                    
                    // Checksum
                    if let checksumRawValue = UserDefaults.standard.object(forKey: "\(decoderType.rawValue)_checksum") as? UInt32 {
                        if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Code11Config {
                            specificConfig.checksum = Code11Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Code25Config {
                            specificConfig.checksum = Code25Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? IATA25Config {
                            specificConfig.checksum = Code25Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Matrix25Config {
                            specificConfig.checksum = Code25Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Datalogic25Config {
                            specificConfig.checksum = Code25Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Datalogic25Config {
                            specificConfig.checksum = Code25Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Interleaved25Config {
                            specificConfig.checksum = Code25Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? Code39Config {
                            specificConfig.checksum = Code39Checksum(rawValue: checksumRawValue)
                        } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? MsiConfig {
                            specificConfig.checksum = MsiChecksum(rawValue: checksumRawValue)
                        }
                    }
                    
                    // Expanding to UPCA
                    if let specificConfig = config.decoderConfig?.getFor(decoderType) as? UpcEConfig {
                        specificConfig.expandToUPCA = UserDefaults.standard.bool(forKey: "\(decoderType.rawValue)_expandToUPCA")
                    } else if let specificConfig = config.decoderConfig?.getFor(decoderType) as? UpcE1Config {
                        specificConfig.expandToUPCA = UserDefaults.standard.bool(forKey: "\(decoderType.rawValue)_expandToUPCA")
                    }
                }
            }
            
            config.regionOfInterestVisible = false
            
            oldConfig.beepOnSuccessEnabled = config.beepOnSuccessEnabled
            oldConfig.vibrateOnSuccessEnabled = config.vibrateOnSuccessEnabled
            oldConfig.decoderConfig = config.decoderConfig
            oldConfig.regionOfInterestVisible = config.regionOfInterestVisible
            oldConfig.closeSessionOnResultEnabled = config.closeSessionOnResultEnabled
            oldConfig.barkoderResolution = config.barkoderResolution
            oldConfig.imageResultEnabled = config.imageResultEnabled
            oldConfig.locationInImageResultEnabled = config.locationInImageResultEnabled
            oldConfig.locationInPreviewEnabled = config.locationInPreviewEnabled
            oldConfig.pinchToZoomEnabled = config.pinchToZoomEnabled
            oldConfig.decoderConfig?.formatting = Formatting(rawValue: config.decoderConfig?.formatting.rawValue ?? 0)
            oldConfig.decoderConfig?.encodingCharacterSet = config.decoderConfig?.encodingCharacterSet ?? ""
            
            completion(config)
        }
    }
    
    static func resetAndReturnBatchScanConfigFor(completion: @escaping (BarkoderConfig) -> Void) {
        ConfigManager.copyConfig { config in
            config.decoderConfig?.getAvailableDecoders().forEach {
                let decoderType = DecoderType(rawValue: UInt32(truncating: $0))

                let specificConfig = config.decoderConfig?.getFor(decoderType)
                // UPC E1 should be disabled
                specificConfig?.enabled = decoderType != UpcE1
            }
            config.closeSessionOnResultEnabled = false
            
            // TODO: - We should discuss if these changes should go to SDK or only in demo app
            config.decoderConfig?.maximumResultsCount = 200
            config.decoderConfig?.duplicatesDelayMs = 0
            config.setMulticodeCachingEnabled(true)
            config.setMulticodeCachingDuration(1000)
            
            completion(config)
        }
    }
    
    static func exportToCsvFrom(_ vc: UIViewController) {
        let scanLogs = CoreDataHelper.loadScans()
        
        var csvString = ""
        
        scanLogs.forEach { data in
            data.value.forEach { scanLog in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy"

                let symbology = scanLog.symbology ?? "N/A".replacingOccurrences(of: ",", with: "")
                let value = scanLog.value ?? "N/A".replacingOccurrences(of: ",", with: "")
                let date = dateFormatter.string(from: scanLog.dateScanned ?? Date()).replacingOccurrences(of: ",", with: "")
                
                let line = "\(symbology), \(value), \(date)\n"
                
                csvString.append(line)
            }
        }
        
        if let filePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first?
            .appendingPathComponent("scanned_results.csv") {
            do {
                try csvString.write(to: filePath, atomically: true, encoding: .utf8)
                
                let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)

                vc.present(activityViewController, animated: true, completion: nil)
            } catch {
                print("Error writing CSV file: \(error)")
            }
        }
    }
    
    static func exportToCsv(decoderResults: [DecoderResult]) -> URL? {
        var csvString = ""
        
        decoderResults.forEach { decoderResult in
            let symbology = decoderResult.barcodeTypeName.replacingOccurrences(of: ",", with: "")
            let value = decoderResult.textualData.replacingOccurrences(of: ",", with: "")
            let line = "\(symbology), \(value)\n"
            csvString.append(line)
        }
        
        if let filePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first?
            .appendingPathComponent("scanned_results.csv") {
            do {
                try csvString.write(to: filePath, atomically: true, encoding: .utf8)
                
                return filePath
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func exportToCsv(scanLog: ScanLog) -> URL? {
        var csvString = ""
        
        let symbology = scanLog.symbology?.replacingOccurrences(of: ",", with: "") ?? ""
        let value = scanLog.value?.replacingOccurrences(of: ",", with: "") ?? ""
        let line = "\(symbology), \(value)\n"
        csvString.append(line)
        
        if let filePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first?
            .appendingPathComponent("scanned_results.csv") {
            do {
                try csvString.write(to: filePath, atomically: true, encoding: .utf8)
                
                return filePath
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func resetAllApplication() {
        // Templates
        UserDefaults.standard.resetValuesForTemplates()
        
        // Batch scanning
        BKDUtils.resetAndReturnBatchScanConfigFor { resetedBarkoderConfig in
            UserDefaults.standard.saveContinuousBkdConfig(bkdConfig: resetedBarkoderConfig)
            ConfigManager.shared.continuousConfig = resetedBarkoderConfig
        }
        
        // Anycode
        BKDUtils.resetAndReturnConfigFor(oldConfig: ConfigManager.shared.ffaConfig) { resetedBarkoderConfig in
            UserDefaults.standard.saveBkdConfig( bkdConfig: resetedBarkoderConfig)
        }
        
        // Webhook configuration
        UserDefaults.standard.clearWebhookData()
        
        // General settings
        UserDefaults.standard.setVinNarrowViewFinder(false)
        UserDefaults.standard.setFpsFeatureEnabled(false)
        UserDefaults.standard.setDpmBiggerViewFinder(false)
        UserDefaults.standard.setWebhookConfirmationFeedback(false)
        UserDefaults.standard.setWebhookEnableEncode(false)
        UserDefaults.standard.setSearchFeatureEnabled(true)
        UserDefaults.standard.setWebhookFeatureEnabled(true)
        UserDefaults.standard.setSendToWebhookAutomatically(false)
        UserDefaults.standard.setDefaultSearchEngine(searchEngine: .google)
        UserDefaults.standard.setStartScannerAutomatically(enabled: false)
    }
    
    static func getNameFor(_ decoderType: DecoderType, config: BarkoderConfig?) -> String {
        let typeName = config?.decoderConfig?.getFor(decoderType).typeName()
        
        switch decoderType {
        case Datamatrix:
            return "Data matrix"
        case UpcA, UpcE, UpcE1, Ean13, Ean8:
            return typeName?.uppercased() ?? "Unknown"
		case Dotcode:
			return "DotCode"
        default:
            return typeName ?? "Unknown"
        }
    }
    
    static func setDefaultValuesFor(_ showcase: Showcase, barkoderConfig: inout BarkoderConfig?) -> BarkoderConfig? {
        guard let barkoderConfig else {
            return nil
        }
        
        // Disable all decoders
        let emptyDecoders: [NSNumber] = []
        barkoderConfig.decoderConfig?.setEnabledDecoders(emptyDecoders)
        
        // Symbologies
        switch showcase {
        case .misshaped:
            barkoderConfig.decoderConfig?.code128.enabled = true
            barkoderConfig.decoderConfig?.code93.enabled = true
            barkoderConfig.decoderConfig?.code39.enabled = true
            barkoderConfig.decoderConfig?.codabar.enabled = true
            barkoderConfig.decoderConfig?.code11.enabled = true
            barkoderConfig.decoderConfig?.code25.enabled = true
            barkoderConfig.decoderConfig?.interleaved25.enabled = true
            barkoderConfig.decoderConfig?.itf14.enabled = true
            barkoderConfig.decoderConfig?.telepen.enabled = true
        case .deblur:
            barkoderConfig.decoderConfig?.upcA.enabled = true
            barkoderConfig.decoderConfig?.upcE.enabled = true
            barkoderConfig.decoderConfig?.ean13.enabled = true
            barkoderConfig.decoderConfig?.ean8.enabled = true
        }
        
        switch showcase {
        case .misshaped:
            barkoderConfig.decoderConfig?.enableMisshaped1D = true
            barkoderConfig.decoderConfig?.decodingSpeed = .init(rawValue: 2)
            barkoderConfig.barkoderResolution = .high
        case .deblur:
            barkoderConfig.decoderConfig?.upcEanDeblur = true
            barkoderConfig.decoderConfig?.decodingSpeed = .init(rawValue: 2)
            barkoderConfig.barkoderResolution = .high
        }
        
        return barkoderConfig
    }
    
}
