//
//  ArticleDataService.swift
//  KioClip
//

//  Created by 高橋和 on 2025/10/27.
//

import Foundation
import OpenGraph
import SwiftData

@MainActor
final class ArticleDataService {
    private let context: ModelContext

    private let ogpFetcher: (URL) async throws -> OpenGraph

    init(context: ModelContext, ogpFetcher: @escaping (URL) async throws -> OpenGraph) {
        self.context = context
        self.ogpFetcher = ogpFetcher
    }

    convenience init() {
        self.init(
            context: PersistenceController.shared.mainContext,
            ogpFetcher: ArticleDataService.realOGPFetcher)
    }

    func fetchArticles(group: Group? = nil) -> [Article] {
        // グループが指定されている場合は、そのグループのarticlesを直接取得
        if let targetGroup = group {
            let articles = Array(targetGroup.articles)
            let sortedArticles = articles.sorted { $0.createdAt > $1.createdAt }
            return sortedArticles
        }

        // グループが指定されていない場合は，すべての記事を取得
        let descriptor = FetchDescriptor<Article>(
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
            let og = try await ogpFetcher(url)
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

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ 記事の更新に失敗: \(error)")
        }
    }

    func deleteArticle(article: Article) {
        context.delete(article)
        self.saveContext()
    }

    private static func realOGPFetcher(url: URL) async throws -> OpenGraph {
        // 必要な引数だけを渡し、残りはデフォルト値（nilなど）を使う
        return try await OpenGraph.fetch(
            url: url,
            headers: nil,  // 使わないので nil を渡す
            configuration: .default  // デフォルト設定を渡す
        )
    }
}
