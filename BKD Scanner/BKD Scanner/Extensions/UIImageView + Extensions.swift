//
//  UIImageView + Extensions.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 20.10.23.
//

import Foundation
import UIKit

extension UIImage {
    func convertToGrayscale() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue)
        
        guard let grayscaleContext = context else { return nil }
        
        grayscaleContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        if let grayscaleImage = grayscaleContext.makeImage() {
            return UIImage(cgImage: grayscaleImage)
        }
        
        return nil
    }
    
}
