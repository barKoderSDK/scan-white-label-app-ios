//
//  AppColor.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 26.6.24.
//

import Foundation
import UIKit

enum AppColor {
    case brand
    
    var color: UIColor {
        switch self {
        case .brand:
            return UIColor(named: "brand_color") ?? UIColor.clear
        }
    }
}
