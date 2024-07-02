//
//  AppConfig.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 1.7.24.
//

import Foundation

#if SCAN
final class AppConfig {
    
    static let howToUseLink = "https://docs.barkoder.com/en/how-to/demo-app-barKoder"
    static let learnMoreLink = "https://barkoder.com"
    static let termsOfUseLink = "https://barkoder.com/terms-of-use"
    static let testBarcodeLink = "https://barkoder.com/register"
    static let privacyPolicyLink = "https://barkoder.com/privacy-policy"
    static let barkoderLicenseKey = "LICENSE_KEY"
    
}

#elseif BARKODER
final class AppConfig {
    
    static let howToUseLink = "https://docs.barkoder.com/en/how-to/demo-app-barKoder"
    static let learnMoreLink = "https://barkoder.com"
    static let termsOfUseLink = "https://barkoder.com/terms-of-use"
    static let testBarcodeLink = "https://barkoder.com/register"
    static let privacyPolicyLink = "https://barkoder.com/privacy-policy"
    static let barkoderLicenseKey = "LICENSE_KEY"

}
#endif
