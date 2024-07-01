//
//  UserDefaultsExtension.swift
//  BKD Scanner
//
//  Created on 17/03/21.
//

import Foundation
import BarkoderSDK

extension UserDefaults {
    
    private static let BKD_CONFIG_KEY = "bkdConfig"
    private static let CONTINUOUS_BKD_CONFIG_KEY = "continuousBkdConfig"
    private static let START_SCANNER_AUTOMATICALLY_KEY = "startScannerAutomatically"
    private static let HAS_LAUNCHED_KEY = "firstRun"
    private static let LINE_SHARPENING_SETTINGS_KEY = "lineSharpening"
    private static let CONTINUOUS_LINE_SHARPENING_SETTINGS_KEY = "continuousLineSharpening"
    private static let DEFAULT_SEARCH_ENGINE = "default_search_engine"
    private static let WEBHOOK_FEATURE_DISABLED = "webhook_feature_disabled"
    private static let SEARCH_FEATURE_DISABLED = "search_feature_disabled"
    private static let WEBHOOK_URL = "webhook_url"
    private static let WEBHOOK_SECRET_WORD = "webhook_secret_word"
    private static let SEND_WEBHOOK_AUTOMATICALLY_KEY = "send_to_webhook_automatically"
    private static let WEBHOOK_CONFIRMATION_FEEDBACK = "webhook_confirmation_feedback"
    private static let WEBHOOK_ENCODE_VALUE = "webhook_encode_value"
    private static let DPM_BIGGER_VIEWFINDER = "dpm_bigger_viewfinder"
    private static let VIN_NARROW_VIEWFINDER = "vin_narrow_viewfinder"
    private static let USER_APP_VERSION = "user_app_version"
    private static let FPS_FEATURE_ENABLED = "fps_feature_enabled"
    private static let AUTOMATIC_SHOW_BOTTOM_SHEET = "automatic_show_bottom_sheet"

    func saveBkdConfig(bkdConfig: BarkoderConfig) {
        let encodedData = BarkoderHelper.configToJSON(bkdConfig)?.data(using: .utf8)
        setValue(encodedData, forKey: UserDefaults.BKD_CONFIG_KEY)
    }
    
    func getBkdConfigData() -> Data? {
        return data(forKey: UserDefaults.BKD_CONFIG_KEY)
    }
    
    func saveContinuousBkdConfig(bkdConfig: BarkoderConfig) {
        let encodedData = BarkoderHelper.configToJSON(bkdConfig)?.data(using: .utf8)
        setValue(encodedData, forKey: UserDefaults.CONTINUOUS_BKD_CONFIG_KEY)
    }
    
    func getContinuousBkdConfigData() -> Data? {
        return data(forKey: UserDefaults.CONTINUOUS_BKD_CONFIG_KEY)
    }
    
    func saveBkdConfigFor(_ template: BarkoderHelper.BarkoderConfigTemplate, bkdConfig: BarkoderConfig) {
        let encodedData = BarkoderHelper.configToJSON(bkdConfig)?.data(using: .utf8)
        setValue(encodedData, forKey: "\(UserDefaults.BKD_CONFIG_KEY)_\(template.rawValue)")
    }
    
    func getBkdConfigDataFor(_ template: BarkoderHelper.BarkoderConfigTemplate) -> Data? {
        return data(forKey: "\(UserDefaults.BKD_CONFIG_KEY)_\(template.rawValue)")
    }
    
    func saveBkdConfigFor(_ showcase: Showcase, bkdConfig: BarkoderConfig) {
        let encodedData = BarkoderHelper.configToJSON(bkdConfig)?.data(using: .utf8)
        setValue(encodedData, forKey: "\(UserDefaults.BKD_CONFIG_KEY)_\(showcase.rawValue)")
    }
    
    func getBkdConfigDataFor(_ showcase: Showcase) -> Data? {
        return data(forKey: "\(UserDefaults.BKD_CONFIG_KEY)_\(showcase.rawValue)")
    }

    func setStartScannerAutomatically(enabled: Bool) {
        set(enabled, forKey: UserDefaults.START_SCANNER_AUTOMATICALLY_KEY)
    }

    func getStartScannerAutomatically() -> Bool {
        return bool(forKey: UserDefaults.START_SCANNER_AUTOMATICALLY_KEY)
    }
    
    func wasLaunchedOnce() -> Bool {
        return bool(forKey: UserDefaults.HAS_LAUNCHED_KEY)
    }
    
    func setWasLaunchedBefore() {
        set(true, forKey: UserDefaults.HAS_LAUNCHED_KEY)
    }
        
    func setLineSharpeningEnabled(enabled: Bool) {
        set(enabled, forKey: UserDefaults.LINE_SHARPENING_SETTINGS_KEY)
    }

    func getLineSharpeningEnabled() -> Bool {
        return bool(forKey: UserDefaults.LINE_SHARPENING_SETTINGS_KEY)
    }

    func setContinuousLineSharpeningEnabled(enabled: Bool) {
        set(enabled, forKey: UserDefaults.CONTINUOUS_LINE_SHARPENING_SETTINGS_KEY)
    }

    func getContinuousLineSharpeningEnabled() -> Bool {
        return bool(forKey: UserDefaults.CONTINUOUS_LINE_SHARPENING_SETTINGS_KEY)
    }
    
    func getDefaultSearchEngine() -> String {
        return string(forKey: UserDefaults.DEFAULT_SEARCH_ENGINE) ?? SearchEngine.google.rawValue
    }
    
    func setDefaultSearchEngine(searchEngine: SearchEngine) {
        set(searchEngine.rawValue, forKey: UserDefaults.DEFAULT_SEARCH_ENGINE)
    }
    
    func setWebhookUrl(urlString: String) {
        set(urlString, forKey: UserDefaults.WEBHOOK_URL)
    }
    
    func getWebhookUrl() -> String? {
        return string(forKey: UserDefaults.WEBHOOK_URL)
    }
    
    func setWebhookSecretWord(key: String) {
        set(key, forKey: UserDefaults.WEBHOOK_SECRET_WORD)
    }
    
    func getWebhookSecretWord() -> String? {
        return string(forKey: UserDefaults.WEBHOOK_SECRET_WORD)
    }
    
    func clearWebhookData() {
        set(nil, forKey: UserDefaults.WEBHOOK_URL)
        set(nil, forKey: UserDefaults.WEBHOOK_SECRET_WORD)
    }
    
    func setSendToWebhookAutomatically(_ bool: Bool) {
        set(bool, forKey: UserDefaults.SEND_WEBHOOK_AUTOMATICALLY_KEY)
    }
    
    func getSendToWebhookAutomatically() -> Bool {
        return bool(forKey: UserDefaults.SEND_WEBHOOK_AUTOMATICALLY_KEY)
    }
    
    func setWebhookFeatureEnabled(_ bool: Bool) {
        set(!bool, forKey: UserDefaults.WEBHOOK_FEATURE_DISABLED)
    }
    
    func getWebhookFeatureEnabled() -> Bool {
        return !bool(forKey: UserDefaults.WEBHOOK_FEATURE_DISABLED)
    }
    
    func setSearchFeatureEnabled(_ bool: Bool) {
        set(!bool, forKey: UserDefaults.SEARCH_FEATURE_DISABLED)
    }
    
    func getSearchFeatureEnabled() -> Bool {
        return !bool(forKey: UserDefaults.SEARCH_FEATURE_DISABLED)
    }
    
    func setWebhookConfirmationFeedback(_ bool: Bool) {
        set(bool, forKey: UserDefaults.WEBHOOK_CONFIRMATION_FEEDBACK)
    }

    func getWebhookConfirmationFeedback() -> Bool {
        return bool(forKey: UserDefaults.WEBHOOK_CONFIRMATION_FEEDBACK)
    }

    func setWebhookEnableEncode(_ bool: Bool) {
        set(bool, forKey: UserDefaults.WEBHOOK_ENCODE_VALUE)
    }

    func getWebhookEnableEncode() -> Bool {
        return bool(forKey: UserDefaults.WEBHOOK_ENCODE_VALUE)
    }
    
    func setDpmBiggerViewFinder(_ bool: Bool) {
        set(bool, forKey: UserDefaults.DPM_BIGGER_VIEWFINDER)
    }
    
    func getDpmBiggerViewFinder() -> Bool {
        return bool(forKey: UserDefaults.DPM_BIGGER_VIEWFINDER)
    }
    
    func setVinNarrowViewFinder(_ bool: Bool) {
        set(bool, forKey: UserDefaults.VIN_NARROW_VIEWFINDER)
    }
    
    func getVinNarrowViewFinder() -> Bool {
        return bool(forKey: UserDefaults.VIN_NARROW_VIEWFINDER)
    }
    
    func setFpsFeatureEnabled(_ bool: Bool) {
        set(bool, forKey: UserDefaults.FPS_FEATURE_ENABLED)
    }
    
    func getFpsFeatureEnabled() -> Bool {
        return bool(forKey: UserDefaults.FPS_FEATURE_ENABLED)
    }
    
    func setAutomaticShowBottomSheet(_ bool: Bool, for flag: String) {
        set(bool, forKey: "\(UserDefaults.AUTOMATIC_SHOW_BOTTOM_SHEET)_\(flag)")
    }
    
    func getAutomaticShowBottomSheet(for flag: String) -> Bool {
        return bool(forKey: "\(UserDefaults.AUTOMATIC_SHOW_BOTTOM_SHEET)_\(flag)")
    }

    /// Used for setting user app version
    /// If the user has updated the version, it will reset local cache for saved template's config
    func setUserAppVersion() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return
        }
        
        let currentAppVersion = String(format: "%@(%@)", appVersion, buildNumber)
        
        if let oldAppVersion = string(forKey: UserDefaults.USER_APP_VERSION) {
            if oldAppVersion != currentAppVersion {
                resetValuesForTemplates()
            }
        } else {
            resetValuesForTemplates()
        }
        
        set(currentAppVersion, forKey: UserDefaults.USER_APP_VERSION)
    }
    
    func resetValuesForTemplates() {
        // Resetting cache for all available templates
        let allTemplates: [BarkoderHelper.BarkoderConfigTemplate] = [
            .all,
            .all_2d,
            .dpm,
            .industrial_1d,
            .pdf_optimized,
            .qr,
            .retail_1d,
            .vin,
            .dotcode,
			.all_1d
        ]
        
        allTemplates.forEach { template in
            setValue(nil, forKey: "\(UserDefaults.BKD_CONFIG_KEY)_\(template.rawValue)")
        }
        
        for showcase in Showcase.allCases {
            setValue(nil, forKey: "\(UserDefaults.BKD_CONFIG_KEY)_\(showcase.rawValue)")
        }
                
        // Default values for showing automatic showing is true
        allTemplates.forEach { template in
            setAutomaticShowBottomSheet(true, for: String(template.rawValue))
        }
        Showcase.allCases.forEach { showcase in
            setAutomaticShowBottomSheet(true, for: String(showcase.rawValue))
        }
        setAutomaticShowBottomSheet(true, for: "all")
        setAutomaticShowBottomSheet(true, for: "general")
        setAutomaticShowBottomSheet(false, for: "batch")

    }

}

public enum Showcase: String, CaseIterable {
    case misshaped
    case deblur
}
