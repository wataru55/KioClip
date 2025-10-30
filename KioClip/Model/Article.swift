//
//  Article.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/10.
//

import UIKit
import SwiftData

@Model
final class Article {
    public private(set) var id: String
    public private(set) var createdAt: Date
    public private(set) var url: String
    var groupName: String?
    
    @Relationship(deleteRule: .cascade)
    var ogp: OpenGraphData?
    
    init(url: String, groupName: String? = nil) {
        self.id = UUID().uuidString
        self.createdAt = Date()
        self.url = url
        self.groupName = groupName
    }
}
