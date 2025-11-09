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
    
    @Relationship(deleteRule: .nullify)
    var groups: [Group] = []
    
    @Relationship(deleteRule: .cascade)
    var ogp: OpenGraphData?
    
    init(url: String, createdAt: Date = Date()) {
        self.id = UUID().uuidString
        self.createdAt = createdAt
        self.url = url
    }
}
