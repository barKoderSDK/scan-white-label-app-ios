//
//  NavigationCell.swift
//  BKD Scanner
//
//  Created on 17/03/21.
//

import UIKit

class NavigationCell: UITableViewCell, Configurable {
    
    static let IDENTIFIER = "NavigationCell"

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpAppearance()
    }
    
    private func setUpAppearance() {
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        accessoryType = .disclosureIndicator
        selectionStyle = .default
    }
    
    func configure(with row: Row) {
        if let row = row as? NavigationRow {
            textLabel?.text = row.title
            detailTextLabel?.text = row.selectedOptionTitle()
            isUserInteractionEnabled = row.isCellClickable
            contentView.alpha = row.isCellClickable ? 1 : 0.6
            textLabel?.textColor = row.isCellClickable ? .black : .systemGray.withAlphaComponent(0.7)
        }
    }

}
