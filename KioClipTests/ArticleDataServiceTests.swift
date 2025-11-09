//
//  ArticleDataServiceTests.swift
//  KioClipTests
//
//  Created by 高橋和 on 2025/11/09.
//

import Foundation
import OpenGraph
import SwiftData
import XCTest

@testable import KioClip

typealias OGPFetchHandler = (URL) async throws -> OpenGraph

@MainActor
class ArticleDataServiceTests: XCTestCase {
    var sut: ArticleDataService!

    var testContext: ModelContext!

    private static let noOpOGPFetcher: OGPFetchHandler = { _ in
        // 🚨 注意: OpenGraph() の初期化が public でないとエラーになるぞ
        return OpenGraph(htmlString: "")  // 何も持たない空のダミーを返す
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        let schema = Schema([Article.self, Group.self, OpenGraphData.self])

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: schema, configurations: [config])

        self.testContext = ModelContext(container)
        self.sut = ArticleDataService(context: testContext, ogpFetcher: Self.noOpOGPFetcher)
    }

    override func tearDownWithError() throws {
        sut = nil
        testContext = nil
        try super.tearDownWithError()
    }

    func testDeleteArticle_WhenOneArticleExist_ShouldReturnEmptyArray() {
        // Arrange
        let article = Article(url: "https://google.com")
        testContext.insert(article)
        // Act
        sut.deleteArticle(article: article)
        // Assert
        let remainingArticles = sut.fetchArticles()
        XCTAssertTrue(remainingArticles.isEmpty, "記事が削除された後、配列は空であるべきじゃ")
    }

    func testFetchArticles_WhenGroupIsNil_ShouldReturnAllSortedByCreatedAt() {
        // Arrange
        let oldDate = Date().addingTimeInterval(-100)
        let currentDate = Date()

        let oldArticle = Article(url: "https://example1.com", createdAt: oldDate)
        let currentArticle = Article(url: "https://example2.com", createdAt: currentDate)

        testContext.insert(oldArticle)
        testContext.insert(currentArticle)

        // Act
        let articles = sut.fetchArticles(group: nil)

        // Assert
        XCTAssertEqual(articles.count, 2, "すべての記事が取得されるべき")
        XCTAssertEqual(articles[0].url, "https://example2.com", "最新の記事が最初に来るべき")
        XCTAssertEqual(articles[1].url, "https://example1.com", " 古い記事が後に来るべき")
    }

    func testFetchArticles_WhenGroupSelect_ShouldReturnCollectArticles() {
        let oldDate = Date().addingTimeInterval(-300)
        let currentDate = Date()
        // Arrange
        let oldArticleInGroup = Article(url: "https://example1.com", createdAt: oldDate)
        let otherArticle = Article(url: "https://example2.com", createdAt: currentDate)
        let currentArticleInGroup = Article(url: "https://example3.com", createdAt: currentDate)

        let testGroup = Group(name: "Test")

        testContext.insert(oldArticleInGroup)
        testContext.insert(otherArticle)
        testContext.insert(currentArticleInGroup)
        testContext.insert(testGroup)

        testGroup.articles.append(oldArticleInGroup)
        testGroup.articles.append(currentArticleInGroup)

        // Act
        let articles = sut.fetchArticles(group: testGroup)

        // Assert
        XCTAssertEqual(articles.count, 2, "グループに属する記事のみが取得されるべき")
        XCTAssertEqual(articles[0].url, "https://example3.com", "最新の記事が最初に来るべき")
        XCTAssertEqual(articles[1].url, "https://example1.com", " 古い記事が後に来るべき")
    }

    func testFetchAndCacheOGP_WhenOGPIsNil_ShouldFetchAndSaveOGP() async throws {
        // 1. 準備 (Arrange)
        // 偽のOGPFetcherが返す情報を定義しておく
        let expectedTitle = "師匠の教え"
        let expectedImageURL = "https://example.com/shisho.jpg"

        // 偽のOGPFetcherを作成。どんなURLが来ても、上で定義した固定のOGPを返すようにする
        let mockOGPFetcher: OGPFetchHandler = { _ in
            // OpenGraphライブラリの仕様上、HTML文字列から初期化する必要がある
            let dummyHtml = """
                <meta property="og:title" content="\(expectedTitle)">
                <meta property="og:image" content="\(expectedImageURL)">
                """
            return OpenGraph(htmlString: dummyHtml)
        }

        // このテストケース専用に、偽のFetcherでsutを上書きする
        sut = ArticleDataService(context: testContext, ogpFetcher: mockOGPFetcher)

        // テスト対象の記事を作成し、DBに保存
        let article = Article(url: "https://some-valid-url.com")
        testContext.insert(article)

        // 初期状態ではOGPはnilのはずじゃ
        XCTAssertNil(article.ogp, "初期状態ではOGPはnilであるべき")

        // 2. 実行 (Act)
        await sut.fetchAndCacheOGP(articleID: article.id)

        // 3. 検証 (Assert)
        // DBから最新の状態の記事を取得し直す
        let articleID = article.id
        let updatedArticleDescriptor = FetchDescriptor<Article>(
            predicate: #Predicate { $0.id == articleID })
        let updatedArticle = try testContext.fetch(updatedArticleDescriptor).first

        XCTAssertNotNil(updatedArticle?.ogp, "OGPがフェッチされ、保存されているべき")
        XCTAssertEqual(updatedArticle?.ogp?.title, expectedTitle, "保存されたOGPのタイトルが期待値と一致すべき")
        XCTAssertEqual(
            updatedArticle?.ogp?.imageURLString, expectedImageURL, "保存されたOGPの画像URLが期待値と一致すべき")
    }

    func testFetchAndCacheOGP_WhenOGPFetcherThrowsError_ShouldNotSaveOGP() async throws {
        // Arrange
        let mockOGPFetcher: OGPFetchHandler = { _ in
            throw NSError(domain: "test", code: 100, userInfo: nil)
        }
        sut = ArticleDataService(context: testContext, ogpFetcher: mockOGPFetcher)
        let article = Article(url: "https://some-valid-url.com")
        testContext.insert(article)
    }

}
