//
//  ModalViewController.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/11.
//

import UIKit

class ModalViewController: UIViewController {

    let type: ModalViewControllerType
    weak var delegate: HalfModalViewControllerDelegate?

    init(type: ModalViewControllerType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupInputTextField()

        // 背景色を設定（表示されたことが分かりやすいように）
        view.backgroundColor = .systemGray6
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didDismissModal()
    }

    private func setupNavigationBar() {
        // 1. 中央にタイトルを設定
        self.title = type.navBarTitle

        // 2. 左側に閉じるボタンを設置
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = closeButton

        // 3. 右側に追加ボタンを設置
        // "追加" という文字列のボタンを作成
        let customTextButton = UIBarButtonItem(
            title: "追加",  // ← ここで好きな文字列を指定
            style: .done,  // .doneにすると太字になる
            target: self,
            action: #selector(addButtonTapped)
        )

        // 必要であれば文字の色も変えられる
        customTextButton.tintColor = .systemGreen

        self.navigationItem.rightBarButtonItem = customTextButton
    }

    private func setupInputTextField() {
        let inputTextField = InputTextField(type: type.textFieldType)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputTextField)

        NSLayoutConstraint.activate([
            inputTextField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            inputTextField.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            inputTextField.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func closeButtonTapped() {
        print("閉じるボタンがタップされた")
        mainStore.dispatch(action: .dismissModal)
    }

    @objc private func addButtonTapped() {
        print("追加ボタンがタップされた！")
        // ここに追加ボタンの処理を書く
    }

}

protocol HalfModalViewControllerDelegate: AnyObject {
    func didDismissModal()
}
