//
//  AppAction.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/10.
//

import Foundation

// アプリケーションで起こりうる操作（Action）を定義する
enum AppAction {
    // グループまたは記事のモーダルを表示する意志
    case presentModal(type: ModalViewControllerType)

    // モーダルを閉じる意志
    case dismissModal
}
