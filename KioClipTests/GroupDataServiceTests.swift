//
//  GroupDataServiceTests.swift
//  KioClipTests
//
//  Created by 高橋和 on 2025/11/08.
//

import Foundation
import SwiftData
import XCTest
@testable import KioClip

@MainActor
final class GroupDataServiceTests: XCTestCase {
    // テスト対象 (System Under Test) を保持する変数
    var sut: GroupDataService!
    
    // テスト用の偽データベース（コンテキスト）
    var testContext: ModelContext!
    
    //MARK: - setup
    // 各テストの前に呼ばれる
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // コンテナにどんなデータ型を格納するか
        let schema = Schema([Group.self])
        // 1.「インメモリ（メモリ上）でのみ動作する」という設定を作る
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        // 2. その設定で、テスト用のコンテナ（金庫）を作る
        //    (Group.self の部分に、テストで使いたいモデルクラスを列挙する)
        let container = try ModelContainer(for: schema, configurations: config)
        
        testContext = ModelContext(container)
        
        sut = GroupDataService(context: testContext)
        
    }
    
    //MARK: - teardown
    // 各テストの後に呼ばれる
    override func tearDownWithError() throws {
        sut = nil
        testContext = nil
        try super.tearDownWithError()
    }
    
    //MARK: - TestsExapmles
    func testFetchGroups_WhenNoGroupsExist_ShouldReturnEmptyArray() {
        // Arrange
        // テスト用コンテキストは空の状態
        // Act
        let groups = sut.fetchGroups()
        // Assert
        XCTAssertTrue(groups.isEmpty, "グループが存在しない場合、空の配列を返すべきです。")
    }
    
    func testFetchGroups_WhenOneGroupExist_ShouldReturnSingleArray() {
        // Arrange
        let group = Group(name: "Swift")
        testContext.insert(group)
        
        // Act
        let groups = sut.fetchGroups()
        
        // Assert
        XCTAssertEqual(groups.count, 1, "1つのグループが存在する場合,配列の要素数は1であるべき.")
        XCTAssertEqual(groups.first?.name, "Swift", "取得したグループの名前が正しいことを確認.")
    }
    
    func testFetchGroups_WhenManyGroupExist_ShouldReturnNameOrderArray() {
        // Arrange
        let groupA = Group(name: "Alpha")
        let groupB = Group(name: "Beta")
        let groupC = Group(name: "Gamma")
        testContext.insert(groupA)
        testContext.insert(groupB)
        testContext.insert(groupC)
        
        // Act
        let groups = sut.fetchGroups()
        
        // Assert
        XCTAssertEqual(groups.count, 3, "3つのグループが存在する場合,配列の要素数は3であるべき.")
        XCTAssertEqual(groups[0].name, "Alpha", "最初のグループは名前順でAlphaであるべき.")
        XCTAssertEqual(groups[1].name, "Beta", "2番目のグループは名前順でBetaであるべき.")
        XCTAssertEqual(groups[2].name, "Gamma", "3番目のグループは名前順でGammaであるべき.")
        
    }
}


