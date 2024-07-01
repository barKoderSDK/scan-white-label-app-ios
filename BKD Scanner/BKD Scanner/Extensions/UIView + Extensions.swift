//
//  UIView + Extensions.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 18.10.23.
//

import Foundation
import UIKit

extension UIView {
    
    func addShadow() {
        let shadowColor = UIColor.gray.cgColor
        let shadowOffset = CGSize(width: 2.0, height: 3.0)
        let cornerRadius = CGFloat(28)
        let shadowOpacity = Float(0.15)
        layer.backgroundColor = UIColor.white.cgColor
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowOpacity = shadowOpacity
    }
    
}
