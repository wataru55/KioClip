//
//  ArticleDataService.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/27.
//

import Foundation
import SwiftData

@MainActor
final class ArticleDataService {
    private let context: ModelContext
    
    init() {
        self.context = PersistenceController.shared.mainContext
    }
    
    func fetchArticles() -> [Article] {
        // FetchDescriptor(取得したいデータの注文書のようなもの)を作成
        // createdAtの降順（新しい順）でソート
        let descriptor = FetchDescriptor<Article>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            // Contextにリクエストを投げて、データを取得
            let fetchedArticles = try context.fetch(descriptor)
            print("✅ \(fetchedArticles.count)件の記事を取得しました。")
            return fetchedArticles
        } catch {
            print("❌ 記事の取得に失敗しました: \(error)")
            return []
        }
    }
}
