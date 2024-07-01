//
//  UITableViewExtension.swift
//  BarkoderView
//
//  Created by Filip Siljavski on 20/04/22.
//

import Foundation
import UIKit

extension UITableView {
    
    public func clearSelection() {
        if let selectedRow = self.indexPathForSelectedRow {
            self.deselectRow(at: selectedRow, animated: true)
        }
    }
    
}
