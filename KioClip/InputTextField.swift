//
//  inputTextField.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/12.
//

import UIKit

enum TextFieldType {
    case group
    case article

    var placeholder: String {
        switch self {
        case .group:
            return "グループ名を入力"
        case .article:
            return "URLの入力または貼り付け"
        }
    }

    var keyboardtype: UIKeyboardType {
        switch self {
        case .group:
            return .default
        case .article:
            return .URL
        }
    }
}

final class InputTextField: UITextField {
    let type: TextFieldType

    init(type: TextFieldType) {
        self.type = type  // ← プロパティを設定
        super.init(frame: .zero)  // ← 親クラスの初期化
        setupUI()
    }

    // StoryboardやXIBから生成された時に呼ばれる初期化処理
    // 今回は使わないが書くのが作法
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        // プレースホルダー（未入力時に表示される薄いテキスト）
        placeholder = type.placeholder

        // 枠線のスタイル
        borderStyle = .none
        layer.cornerRadius = 12
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray3.cgColor

        // 3. (おまけ) 影をつける
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)  // 影の方向
        layer.shadowRadius = 4.0

        // 1. 左側に配置する「空のView」を作成
        //    widthを10にすることで、10ptの余白ができる
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))

        // 2. leftViewに、その空のViewを割り当てる
        leftView = paddingView
        // 3. leftViewを常に表示するように設定する
        leftViewMode = .always

        // キーボードの種類 (他にも .numberPad, .emailAddress など)
        keyboardType = type.keyboardtype

        // リターンキーの見た目 (他にも .next, .search など)
        returnKeyType = .done

        // 入力内容を隠すか (パスワード用)
        isSecureTextEntry = false

        // 入力内容を全消去する「×」ボタンの表示モード
        clearButtonMode = .always
        // 背景色や文字色
        backgroundColor = .systemGray6
        textColor = .darkText
    }
}
