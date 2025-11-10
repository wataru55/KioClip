//
//  AppState.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/10.
//

import Foundation

// アプリケーション全体の「状態」を定義する
struct AppState {
    // モーダル表示に関する状態
    var modalPresentation = ModalPresentationState()

    // ... いずれここに、グループのリストや記事のリストなどの状態も追加していくことになる ...
}

// モーダル表示に特化した状態
struct ModalPresentationState: Equatable {
    var isPresented: Bool = false
    var modalType: ModalViewControllerType?
}
