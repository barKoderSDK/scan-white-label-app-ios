//
//  SubtitleRow.swift
//  BKD Scanner
//
//  Created by Filip Siljavski on 29/06/22.
//

import Foundation
import UIKit

class SubtitleRow: Row {
    
    var title: String
    var reuseIdentifier = SubtitleCell.IDENTIFIER
    var cellType: UITableViewCell.Type = SubtitleCell.self
    
    internal init(title: String) {
        self.title = title
    }
    
}
