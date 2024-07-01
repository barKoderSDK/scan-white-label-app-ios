//
//  SwitchRow.swift
//  BKD Scanner
//
//  Created on 16/03/21.
//

import UIKit

class SwitchRow: Row {
    
    var onSwitch: ((Bool) -> Void)?
    var title: String
    var cellType: UITableViewCell.Type = SwitchCell.self
    let reuseIdentifier = SwitchCell.IDENTIFIER
    var additionalSettingsAction: (() -> Void)?
    var isCellClickable: Bool
    var isOn = false {
        didSet {
            guard isOn != oldValue else {
                return
            }
            
            self.onSwitch?(self.isOn)
        }
    }
    var hasAdditionalSettings: Bool
    
    convenience init(title: String, isOn: Bool, hasAdditionalSettings: Bool, isCellClickable: Bool = true, onSwitch: ((Bool) -> Void)?) {
        self.init(title: title, isOn: isOn, hasAdditionalSettings: hasAdditionalSettings, isCellClickable: isCellClickable, onSwitch: onSwitch, additionalSettingsAction: nil)
    }
    
    init(title: String, isOn: Bool, hasAdditionalSettings: Bool, isCellClickable: Bool, onSwitch: ((Bool) -> Void)?, additionalSettingsAction: (() -> Void)?) {
        self.title = title
        self.isOn = isOn
        self.onSwitch = onSwitch
        self.hasAdditionalSettings = hasAdditionalSettings
        self.additionalSettingsAction = additionalSettingsAction
        self.isCellClickable = isCellClickable
    }
    
}
