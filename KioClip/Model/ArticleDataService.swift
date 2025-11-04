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
    
    func fetchArticles(group: Group? = nil) -> [Article] {
        // FetchDescriptor(取得したいデータの注文書のようなもの)を作成する
        // 絞り込み条件（Predicate）を "変数" として用意
        var predicate: Predicate<Article>? = nil
        
        if let targetGroup = group {
            let targetGroupID = targetGroup.persistentModelID
            predicate = #Predicate<Article> { $0.group?.persistentModelID == targetGroupID }
        }
        
        let descriptor = FetchDescriptor<Article>(
            predicate: predicate,
            sortBy: [SortDescriptor<Article>(\.createdAt, order: .reverse)]
        )
            
        do {
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
        
        guard let url = URL(string: article.url) else {
            print("❌ 無効なURL: \(article.url)")
            return
        }
        
        do {
            let og = try await OpenGraph.fetch(url: url)
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
    
    func updateArticle(article: Article) {
        do {
            try context.save()
        } catch {
            print("❌ 記事の更新に失敗: \(error)")
        }
    }
    
    func deleteArticle(article: Article) {
        context.delete(article)
        
        do {
            try context.save()
        } catch {
            print("❌ 記事の削除に失敗: \(error)")
        }
    }
}
