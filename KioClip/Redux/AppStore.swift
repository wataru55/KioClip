//
//  AppStore.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/10.
//

import Foundation

final class AppStore {

    // 現在の状態を保持する。private(set)で、外部からの直接の書き換えを防ぐ。
    // 状態の変更はdispatchを通じてのみ行われるべきじゃ。
    private(set) var state: AppState

    // 状態を更新するためのReducer
    private let reducer: (inout AppState, AppAction) -> Void

    // 状態の変更を監視する者（Subscriber）たちを保持する配列
    private var subscribers: [() -> Void] = []

    // 初期状態とReducerを受け取ってStoreを生成する
    init(initialState: AppState, reducer: @escaping (inout AppState, AppAction) -> Void) {
        self.state = initialState
        self.reducer = reducer
    }

    // ActionをStoreに送る（Dispatchする）ための唯一のメソッド
    func dispatch(action: AppAction) {
        // Reducerを呼び出して、現在の状態を更新する
        reducer(&state, action)

        // 状態が更新されたことを、すべてのSubscriberに通知する
        subscribers.forEach { $0() }
    }

    // 状態の変更を監視したい者（ViewControllerなど）が登録するためのメソッド
    func subscribe(_ subscriber: @escaping () -> Void) {
        // 監視者リストに追加する
        self.subscribers.append(subscriber)
    }
}
