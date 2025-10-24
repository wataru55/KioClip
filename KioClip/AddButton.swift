//
//  AddButton.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/10.
//

import UIKit

final class AddButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 初期設定を行うメソッドを呼ぶ
        setupButton()
    }

    // StoryboardやXIBから生成された時に呼ばれる初期化処理
    // 今回は使わないが書くのが作法
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ボタンの見た目を設定するプライベートメソッド
    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false

        let plusImage = UIImage(systemName: "plus")
        setImage(plusImage, for: .normal)

        tintColor = .white
        backgroundColor = .systemGreen
        // 常に円になるように、レイアウト後に角丸を計算する
        layer.masksToBounds = true
    }

    // layoutSubviews() はAutoLayoutの計算が終了した後に呼ばれる
    // ここで角丸を設定すれば、ボタンサイズが変わっても追従できる
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }

}
