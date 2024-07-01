//
//  MainCollectionViewCell.swift
//  BKD Scanner
//
//  Created by Filip Siljavski on 20/06/22.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func setUpAppearance() {
        let shadowColor = UIColor.gray.cgColor
        let shadowOffset = CGSize(width: 2.0, height: 2.0)
        let cornerRadius = CGFloat(20)
        let shadowOpacity = Float(0.15)
        layer.backgroundColor = UIColor.white.cgColor
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowOpacity = shadowOpacity
    }
    
}
