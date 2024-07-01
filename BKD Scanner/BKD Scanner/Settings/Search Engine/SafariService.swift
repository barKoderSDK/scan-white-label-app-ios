//
//  SafariService.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 6.10.23.
//

import Foundation
import SafariServices

final class SafariService {
    
    static func searchWebFor(_ keyword: String, vc: UIViewController) {
        let searchEngine = SearchEngine(rawValue: UserDefaults.standard.getDefaultSearchEngine()) ?? .google
        let searchEngineUrl = searchEngine.urlString
        
        var urlForOpen: URL?
        
        if keyword.isValidURL(), let url = URL(string: keyword) {
            urlForOpen = url
        } else {
            if let string = String(format: searchEngineUrl, keyword).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: string) {
                urlForOpen = url
            }
        }
        
        if let url = urlForOpen {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.modalPresentationStyle = .overFullScreen
                DispatchQueue.main.async {
                    vc.present(safariViewController, animated: true, completion: nil)
                }
            }
        } else {
            vc.showAlertWith("Url is not valid")
        }

    }
    
    static func openDocsForWebhooks(_ vc: UIViewController) {
        guard let url = URL(string: "https://docs.barkoder.com/en/how-to/webhooks") else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        DispatchQueue.main.async {
            vc.present(safariViewController, animated: true, completion: nil)
        }

    }
}
