//
//  UITextfield + Extensions.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 8.11.23.
//

import Foundation
import UIKit

extension UITextField {
    
    func setPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
        rightView = paddingView
        rightViewMode = .always
    }
        
}
