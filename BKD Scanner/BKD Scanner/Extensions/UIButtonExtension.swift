//
//  UIButtonExtension.swift
//  BKD Scanner
//
//  Created on 02/02/21.
//

import Foundation
import UIKit

extension UIButton {
    
    func centerVertically(padding: CGFloat = 0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -5,
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: self.frame.height / 2 + imageViewSize.height / 2,
            left: -imageViewSize.width,
            bottom: 0.0,
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
}
