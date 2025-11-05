//
//  Group.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/04.
//

import Foundation
import SwiftData

@Model
final class Group {
    var name: String
    @Relationship(inverse: \Article.groups)
    var articles: [Article]
    
    init(name: String, articles: [Article] = []) {
        self.name = name
        self.articles = articles
    }
    
}
