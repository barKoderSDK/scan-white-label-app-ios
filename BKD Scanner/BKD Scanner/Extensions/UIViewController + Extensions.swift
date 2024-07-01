//
//  UIViewController + Extensions.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 9.10.23.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertWith(_ title: String, message: String? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            completion?()
        }
        
        alertController.addAction(continueAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }

}
