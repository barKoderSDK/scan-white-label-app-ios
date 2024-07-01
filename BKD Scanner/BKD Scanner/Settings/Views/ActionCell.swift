//
//  ActionCell.swift
//  BKD Scanner
//
//  Created on 19/03/21.
//

import UIKit

class ActionCell: UITableViewCell, Configurable {
    
    static let IDENTIFIER = "ActionCell"

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpAppearance()
    }
    
    private func setUpAppearance() {
        textLabel?.numberOfLines = 0
        selectionStyle = .default
    }
    
    func configure(with row: Row) {
        if let row = row as? ActionRow {
            textLabel?.text = row.title
            textLabel?.textColor = row.titleColor
            detailTextLabel?.text = row.detailText
            isUserInteractionEnabled = row.isCellClickable
            contentView.alpha = row.isCellClickable ? 1 : 0.6
            textLabel?.textColor = row.isCellClickable ? row.titleColor : .systemGray.withAlphaComponent(0.7)
        }
    }

}
