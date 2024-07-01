//
//  ConfigManager.swift
//  BKD Scanner
//
//  Created on 28/12/21.
//

import Foundation
import BarkoderSDK

/// Singleton to keep clean config
final class BarcodeConfigurationManager {
    
    static let shared = BarcodeConfigurationManager()

    lazy var cleanConfig = BarkoderConfig(licenseKey: Constants.LICENCE_KEY) { result in
        if result.code == LC_OK {
            print("License check successful!")
        } else {
            print("License check fail!")
        }
    }
    
    func configure() {
        let _ = BarcodeConfigurationManager.shared.cleanConfig
    }
}

final class ConfigManager {
    
    static let shared = ConfigManager()

    var ffaConfig: BarkoderConfig
    var continuousConfig: BarkoderConfig

    var templateConfig: BarkoderConfig {
        return BarcodeConfigurationManager.shared.cleanConfig
    }
        
    private func saveSymbologiesSettingsToUserDefaults() {
        ffaConfig.decoderConfig?.getAvailableDecoders().forEach {
            let decoderType = DecoderType(rawValue: UInt32(truncating: $0))

            // Saving enabled and lenghts
            if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? SpecificConfig {
                UserDefaults.standard.set(specificConfig.enabled, forKey: "\(decoderType.rawValue)_enabled")
                UserDefaults.standard.set(specificConfig.minimumLength, forKey: "\(decoderType.rawValue)_minimumLength")
                UserDefaults.standard.set(specificConfig.maximumLength, forKey: "\(decoderType.rawValue)_maximumLength")
            }

            // Saving checksums
            if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Code11Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Code25Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? IATA25Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Matrix25Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Datalogic25Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Datalogic25Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Interleaved25Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? Code39Config {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? MsiConfig {
                UserDefaults.standard.set(specificConfig.checksum.rawValue, forKey: "\(decoderType.rawValue)_checksum")
            }
            
            // Expanding to UPCA
            if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? UpcEConfig {
                UserDefaults.standard.set(specificConfig.expandToUPCA, forKey: "\(decoderType.rawValue)_expandToUPCA")
            } else if let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType) as? UpcE1Config {
                UserDefaults.standard.set(specificConfig.expandToUPCA, forKey: "\(decoderType.rawValue)_expandToUPCA")
            }
        }
    }
    
    private init() {
        ffaConfig = BarcodeConfigurationManager.shared.cleanConfig
        continuousConfig = BarcodeConfigurationManager.shared.cleanConfig
        
        if !UserDefaults.standard.wasLaunchedOnce() {
            UserDefaults.standard.setWasLaunchedBefore()
            UserDefaults.standard.setLineSharpeningEnabled(enabled: false)
            UserDefaults.standard.setContinuousLineSharpeningEnabled(enabled: false)

            self.ffaConfig.decoderConfig?.getAvailableDecoders().forEach {
                let decoderType = DecoderType(rawValue: UInt32(truncating: $0))

                let specificConfig = ffaConfig.decoderConfig?.getFor(decoderType)
                
                switch decoderType {
                case UpcE1, Datalogic25, Dotcode:
                    specificConfig?.enabled = false
                default:
                    specificConfig?.enabled = true
                }
            }
            
            ffaConfig.regionOfInterestVisible = false
            
            saveSymbologiesSettingsToUserDefaults()
            
            self.continuousConfig.decoderConfig?.getAvailableDecoders().forEach {
                let decoderType = DecoderType(rawValue: UInt32(truncating: $0))

                let specificConfig = continuousConfig.decoderConfig?.getFor(decoderType)

                switch decoderType {
                case UpcE1, Datalogic25, Dotcode:
                    specificConfig?.enabled = false
                default:
                    specificConfig?.enabled = true
                }
            }
            continuousConfig.closeSessionOnResultEnabled = false
            
            // TODO: - We should discuss if these changes should go to SDK or only in demo app
            continuousConfig.decoderConfig?.maximumResultsCount = 200
            continuousConfig.decoderConfig?.duplicatesDelayMs = 0
            continuousConfig.setMulticodeCachingEnabled(true)
            continuousConfig.setMulticodeCachingDuration(1000)
            
            UserDefaults.standard.saveContinuousBkdConfig(bkdConfig: continuousConfig)
        } else {
            if let data = UserDefaults.standard.getBkdConfigData() {
                BarkoderHelper.applyConfigSettingsFromJson(ffaConfig, jsonData: data) { config, error in
                    guard let config = config else { return }
                    
                    self.ffaConfig = config
                }
            }
            
            if let continuousData = UserDefaults.standard.getContinuousBkdConfigData() {
                BarkoderHelper.applyConfigSettingsFromJson(continuousConfig, jsonData: continuousData) { config, error in
                    guard let config = config else { return }
                    self.continuousConfig = config
                    // TODO: - This logic should be from SDK
                    self.continuousConfig.decoderConfig?.maximumResultsCount = 200
                    self.continuousConfig.decoderConfig?.duplicatesDelayMs = 0
                    self.continuousConfig.setMulticodeCachingEnabled(true)
                    self.continuousConfig.setMulticodeCachingDuration(1000)
                }
            }
        }
        
    }
    
    static func getCofigWithTemplate(template: BarkoderHelper.BarkoderConfigTemplate, configLoaded: @escaping (BarkoderConfig) -> Void) {
        let config = BarcodeConfigurationManager.shared.cleanConfig
        
        BarkoderHelper.applyConfigSettingsFromTemplate(config, template: template) { updatedConfig in
            configLoaded(updatedConfig)
        }
    }
    
    static func copyConfig(config: BarkoderConfig, configLoaded: @escaping (BarkoderConfig) -> Void) {
        let continuousConfig = BarkoderConfig(licenseKey: Constants.LICENCE_KEY) { result in
            if result.code == LC_OK {
                print("License check successful!")
            } else {
                print("License check fail!")
            }
        }
        
        guard let encodedData = BarkoderHelper.configToJSON(config)?.data(using: .utf8) else { return }
        
        BarkoderHelper.applyConfigSettingsFromJson(continuousConfig, jsonData: encodedData) { config, error in
            guard let safeConfig = config else { return }
            configLoaded(safeConfig)
        }
    }
    
    static func copyConfig(configLoaded: @escaping (BarkoderConfig) -> Void) {
        let config = BarkoderConfig(licenseKey: Constants.LICENCE_KEY) { result in
            if result.code == LC_OK {
                print("License check successful!")
            } else {
                print("License check fail!")
            }
        }
        
        configLoaded(config)
    }
    
}
