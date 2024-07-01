//
//  SearchEngineEnum.swift
//  BKD Scanner
//
//  Created by Slobodan Marinkovik on 6.10.23.
//

import Foundation

enum SearchEngine: String, CaseIterable {
    case google
    case yahoo
    case duckduckgo
    case yandex
    case bing
    case brave
    
    var title: String {
        switch self {
        case .google:
            return "Google"
        case .yahoo:
            return "Yahoo"
        case .duckduckgo:
            return "DuckDuckGo"
        case .yandex:
            return "Yandex"
        case .bing:
            return "Bing"
        case .brave:
            return "Brave"
        }
    }
    
    var urlString: String {
        switch self {
        case .google:
            return "https://www.google.com/search?q=%@"
        case .yahoo:
            return "https://search.yahoo.com/search?p=%@"
        case .duckduckgo:
            return "https://duckduckgo.com/?q=%@"
        case .yandex:
            return "https://yandex.com/search/?text=%@"
        case .bing:
            return "https://www.bing.com/search?q=%@"
        case .brave:
            return "https://search.brave.com/search?q=%@"
        }
    }
}
