//
//  BarcoderResultExtension.swift
//  BarkoderView
//
//  Created by Filip Siljavski on 22/04/22.
//

import Foundation
import BarkoderSDK

extension DecoderResult {
    
    public func getParsedResultOrTextual() -> String {
        return self.extra["formattedText"] as? String ?? self.textualData
    }
    
}
