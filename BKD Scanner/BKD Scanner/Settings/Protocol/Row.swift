//
//  Row.swift
//  BKD Scanner
//
//  Created on 16/03/21.
//

import UIKit

protocol Row: AnyObject {
    
    var title: String { get set }
    var reuseIdentifier: String { get }
    var cellType: UITableViewCell.Type { get }

}
