//
//  MailServiceViewController.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 17.10.23.
//

import Foundation
import MessageUI

final class MailServiceViewController: UIViewController {
    
    var resultsURL: URL?
    
    init(resultsURL: URL?) {
        self.resultsURL = resultsURL
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sendMail()
    }
        
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            
            mailComposeViewController.setSubject("Results csv")
            mailComposeViewController.setMessageBody("barKoder.", isHTML: false)
            
            if let fileURL = resultsURL {
                if let data = try? Data(contentsOf: fileURL) {
                    mailComposeViewController.addAttachmentData(data, mimeType: "text/csv", fileName: "results.csv")
                }
            }
            
            DispatchQueue.main.async {
                self.present(mailComposeViewController, animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true)
        }
    }
}

extension MailServiceViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            self.dismiss(animated: false)
        }
    }
    
}

