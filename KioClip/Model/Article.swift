//
//  Article.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/10.
//

import SwiftData
import UIKit

@Model
final class Article {
    private(set) var id: String
    private(set) var createdAt: Date
    private(set) var url: String

    @Relationship(deleteRule: .nullify)
    var groups: [Group] = []

    init(url: String, createdAt: Date = Date()) {
        self.id = UUID().uuidString
        self.createdAt = createdAt
        self.url = url
    }
}
