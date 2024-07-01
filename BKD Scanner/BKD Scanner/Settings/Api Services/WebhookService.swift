//
//  WebhookService.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 6.10.23.
//

import Foundation
import Alamofire
import CryptoKit

final class WebhookService {
    
    static func sendWebhook(values: [(String, String)], completion: @escaping (Result<WebhookResponse, BarkoderError>) -> Void) {
        guard let urlString = UserDefaults.standard.getWebhookUrl(),
              let secretWord = UserDefaults.standard.getWebhookSecretWord() else {
            
            completion(.failure(.init(code: 418, description: "")))
            return
        }
        let securityData = String(format: "%.0f", Date().timeIntervalSince1970)

        let securityHash = WebhookService.md5(string: "\(securityData)\(secretWord)")
        
        var serverData = [[String: Any]]()
        
        values.forEach { data in
            // Encrypting value using base64 encoded string
            var barkoderValue: String = data.1
            var symbology: String = data.0
            
            if UserDefaults.standard.getWebhookEnableEncode(),
               let data = barkoderValue.data(using: .utf8),
               let symbologyData = symbology.data(using: .utf8)
            {
                barkoderValue = data.base64EncodedString()
                symbology = symbologyData.base64EncodedString()
            }

            serverData.append([
                "symbology": symbology,
                "value": barkoderValue,
                "date": securityData,
                "base64": UserDefaults.standard.getWebhookEnableEncode()
            ])
        }
        
        let parameters: Parameters = [
            "security_data": securityData,
            "security_hash": securityHash,
            "data": serverData
        ]

        let request = AF.request(
            urlString,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        request
            .validate()
            .responseDecodable(of: WebhookResponse.self, completionHandler: { response in
                if UserDefaults.standard.getWebhookConfirmationFeedback() {
                    switch response.result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(BarkoderError(code: error.responseCode ?? 400, description: error.localizedDescription)))
                    }
                }
            })
    }
    
    fileprivate static func md5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
}

struct WebhookResponse: Codable {
    var status: Bool
    var message: String
}

struct BarkoderError: Error {
    let code: Int
    let description: String
}
