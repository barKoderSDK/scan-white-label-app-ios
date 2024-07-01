//
//  SubtitleCell.swift
//  BKD Scanner
//
//  Created by Filip Siljavski on 29/06/22.
//

import Foundation
import UIKit

class SubtitleCell: UITableViewCell, Configurable {
    
    static let IDENTIFIER = "SubtitleCell"

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
        textLabel?.textColor = UIColor(red: 144/255.0, green: 144/255.0, blue: 144/255.0, alpha: 1)
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        selectionStyle = .none
        backgroundColor = UIColor.white.withAlphaComponent(0)
    }
    
    func configure(with row: Row) {
        if let row = row as? SubtitleRow {
            textLabel?.text = row.title
        }
    }

}
