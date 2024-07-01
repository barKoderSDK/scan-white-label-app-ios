//
//  Foundation + Extensions.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 6.10.23.
//

import Foundation
import UIKit

extension String {
    
    func isValidURL() -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
                return match.range.length == self.utf16.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
}
