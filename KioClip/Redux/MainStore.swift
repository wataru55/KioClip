//
//  MainStore.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/10.
//

import Foundation

// アプリケーション全体で共有される唯一のStoreインスタンス
let mainStore = AppStore(
    initialState: AppState(),  // アプリ起動時の初期状態
    reducer: appReducer  // 状態を更新するためのReducer
)
