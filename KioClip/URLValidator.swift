//
//  URLValidator.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/07.
//

import Foundation

struct URLValidator {
    static func isValidURL(_ urlString: String?) -> Bool {
        guard let urlString = urlString, !urlString.isEmpty else {
            return false
        }
        
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        
        return true
    }
}
