//
//  AppReducer.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/10.
//

import Foundation

func appReducer(state: inout AppState, action: AppAction) {
    // 受け取ったActionの種類によって、Stateの更新処理を分岐させる
    switch action {
    case .presentModal(let type):
        // .presentModalアクションが来た場合...
        // モーダル表示の状態を「表示する」に更新するCannot find type 'AppState' in scope
        state.modalPresentation.isPresented = true
        state.modalPresentation.modalType = type

    case .dismissModal:
        // .dismissModalアクションが来た場合...
        // モーダル表示の状態を「閉じる」に更新する
        state.modalPresentation.isPresented = false
        state.modalPresentation.modalType = nil
    }
}
