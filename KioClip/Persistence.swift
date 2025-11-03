//
//  Persistence.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/25.
//

import Foundation
import SwiftData

final class PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    
    @MainActor
    var mainContext: ModelContext {
        container.mainContext
    }
    
    private init() {
        // スキーマの定義
        let schema = Schema([Article.self, Group.self])
        // モデルコンテナの構成を設定
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            // このクラスが初期化される時に、コンテナを一度だけ作成する
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            print("🗄️ データベースのパス: \(container.configurations.first?.url.path() ?? "不明")")
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
