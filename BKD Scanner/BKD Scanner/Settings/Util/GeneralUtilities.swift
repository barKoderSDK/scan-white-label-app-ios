//
//  GeneralUtilities.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 18.10.23.
//

import Foundation
import UIKit

final class GeneralUtilities {
    
    static func showWebhookExplanationAlert(_ vc: UIViewController, openSettingsCompletion: @escaping () -> Void) {
        let title = "Webhook configuration"
        let message = "The webhook configuration for this application is not set. To enable webhook functionality and ensure proper integration, please configure the webhook settings in your settings dashboard"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let showMeHowAction = UIAlertAction(title: "Show me how", style: .default) { _ in
            SafariService.openDocsForWebhooks(vc)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(showMeHowAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
    }
    
}
