//
//  GroupDataService.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/04.
//

import Foundation
import SwiftData

@MainActor
final class GroupDataService {
    private let context: ModelContext
        
    init() {
        self.context = PersistenceController.shared.mainContext
    }
    
    func fetchGroups() -> [Group] {
        let descriptor = FetchDescriptor<Group>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        do {
            // Contextにリクエストを投げて、データを取得
            let fetchedGroups = try context.fetch(descriptor)
            print("✅ \(fetchedGroups.count)件のgroupを取得しました。")
            return fetchedGroups
        } catch {
            print("❌ 記事の取得に失敗しました: \(error)")
            return []
        }
    }
}
