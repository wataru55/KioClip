//
//  ArticleDataService.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/27.
//

import Foundation
import SwiftData
import OpenGraph

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
    
    func fetchAndCacheOGP(articleID: String) async {
        let descriptor = FetchDescriptor<Article>(
            predicate: #Predicate<Article> { $0.id == articleID }
        )
        guard let article = try? context.fetch(descriptor).first else {
            return
        }
        
        // 2. すでにOGPがあるなら何もしない（キャッシュ利用）
        if article.ogp != nil {
            print("すでに存在しているよ")
            return
        }
        
        do {
            let og = try await OpenGraph.fetch(url: URL(string: article.url)!)
            let fetchedOGP = OpenGraphData(
                title: og[.title],
                imageURLString: og[.image]
            )
            
            context.insert(fetchedOGP)
            article.ogp = fetchedOGP
            fetchedOGP.article = article
            
            try context.save()
            
        } catch {
            print("❌ OGPの保存に失敗: \(error)")
        }
    }
}
