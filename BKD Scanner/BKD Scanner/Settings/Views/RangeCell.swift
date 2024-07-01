//
//  RangeCell.swift
//  BKD Scanner
//
//  Created by Zhivko Manchev on 24.10.22.
//

import Foundation
import UIKit
import TTRangeSlider

public class RangeCell: UITableViewCell {
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var label: UILabel!
    
    static let IDENTIFIER = "RangeCell"
    
    weak var delegate: TTRangeSliderDelegate? {
        didSet {
            rangeSlider.delegate = delegate
        }
    }
}
