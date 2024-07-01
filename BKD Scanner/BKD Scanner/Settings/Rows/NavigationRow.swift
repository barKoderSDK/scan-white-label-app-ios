//
//  NavigationRow.swift
//  BKD Scanner
//
//  Created on 17/03/21.
//

import UIKit

class NavigationRow: Row {
    
    var isCellClickable: Bool
    var onIndexChange: ((Int) -> Void)?

    internal init(title: String, isCellClickable: Bool = true, selectedOptionIndex: Int, options: [String], additionalOptions: [String] = [], onIndexChange: ((Int) -> Void)?) {
        self.title = title
        self.isCellClickable = isCellClickable
        self.options = options
        self.selectedOptionIndex = selectedOptionIndex
        self.additionalOptions = additionalOptions
        self.onIndexChange = onIndexChange
    }
    
    var title: String
    var reuseIdentifier = NavigationCell.IDENTIFIER
    var cellType: UITableViewCell.Type = NavigationCell.self
    var options: [String]
    var additionalOptions: [String]
    var selectedOptionIndex: Int = 0 {
        didSet {
            if selectedOptionIndex != oldValue {
                onIndexChange?(selectedOptionIndex)
            }
        }
    }
    
    func selectedOptionTitle() -> String? {
        return options[selectedOptionIndex]
    }
}
