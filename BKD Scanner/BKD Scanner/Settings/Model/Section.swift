//
//  Section.swift
//  BKD Scanner
//
//  Created on 17/03/21.
//

import UIKit

class Section: NSObject {
    
    init(name: String, rows: [Row] = [Row]()) {
        self.name = name
        self.rows = rows
    }

    var name: String
    var rows: [Row]
    
}
