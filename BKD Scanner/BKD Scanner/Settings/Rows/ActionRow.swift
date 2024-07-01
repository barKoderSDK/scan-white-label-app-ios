//
//  ActionRow.swift
//  BKD Scanner
//
//  Created on 19/03/21.
//

import UIKit

class ActionRow: Row {
    
    var action: (() -> Void)?
    var title: String
    var detailText: String
    var reuseIdentifier = ActionCell.IDENTIFIER
    var cellType: UITableViewCell.Type = ActionCell.self
    var titleColor: UIColor
    var isCellClickable: Bool
    
    internal init(title: String, detailText: String, titleColor: UIColor = .black, isCellClickable: Bool = true, action: (() -> Void)?) {
        self.title = title
        self.detailText = detailText
        self.titleColor = titleColor
        self.isCellClickable = isCellClickable
        self.action = action
    }
    
}
