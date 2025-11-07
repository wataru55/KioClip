//
//  ModalViewController.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/11.
//

import RxCocoa
import RxSwift
import SwiftData
import UIKit

enum ModalViewControllerType {
    case group
    case article

    var navBarTitle: String {
        switch self {
        case .group:
            return "新規グループ"
        case .article:
            return "新規URL"
        }
    }

    var textFieldType: TextFieldType {
        switch self {
        case .group:
            return .group
        case .article:
            return .article
        }
    }
}

class ModalViewController: UIViewController {
    let type: ModalViewControllerType
    let selectedGroup: Group?

    private lazy var inputTextField: InputTextField = {
        let inputTextField = InputTextField(type: type.textFieldType)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        return inputTextField
    }()

    private lazy var context: ModelContext = {
        return PersistenceController.shared.mainContext
    }()
    
    private lazy var customTextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "追加",
            style: .done,
            target: self,
            action: #selector(addButtonTapped)
        )
        button.tintColor = .systemGreen
        
        button.isEnabled = false
        
        return button
    }()

    private let articleDidAddSubject = PublishSubject<Void>()
    private let groupDidAddSubject = PublishSubject<Void>()
    let articleDidAdd: Observable<Void>
    let groupDidAdd: Observable<Void>
    
    private var disposeBag = DisposeBag()

    init(type: ModalViewControllerType, group: Group? = nil) {
        self.type = type
        self.articleDidAdd = articleDidAddSubject.asObservable()
        self.groupDidAdd = groupDidAddSubject.asObservable()
        self.selectedGroup = group
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        articleDidAddSubject.onCompleted()
        groupDidAddSubject.onCompleted()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        setupNavigationBar()
        setupInputTextField()
        setupBinding()
    }

    private func setupNavigationBar() {
        self.title = type.navBarTitle

        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = closeButton

        self.navigationItem.rightBarButtonItem = self.customTextButton
    }

    private func setupInputTextField() {
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
    
    private func setupBinding() {
        inputTextField.rx.text
            .orEmpty
            .map { text in
                return !text.isEmpty
            }
            .bind(to: customTextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func showInvalidURLAlert() {
        let alert = UIAlertController(
            title: "無効なURLです",
            message: "http:// または https:// から始まる\n正しいURLを入力してください。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // (重要) モーダル (self) がアラートを "present" する
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func closeButtonTapped() {
        print("閉じるボタンがタップされた")
        self.dismiss(animated: true)
    }

    @objc private func addButtonTapped() {
        switch type {
        case .article:
            let urlString = inputTextField.text
            
            guard URLValidator.isValidURL(urlString) else {
                if let text = urlString, text.isEmpty {
                    return
                }
                
                showInvalidURLAlert()
                return
            }
            
            let article = Article(url: urlString!)
            context.insert(article)

            if let selectedGroup = self.selectedGroup {
                article.groups.append(selectedGroup)
            }

            do {
                try context.save()
                self.articleDidAddSubject.onNext(())
            } catch {
                print("Error saving article: \(error)")
            }

        case .group:
            guard let groupName = inputTextField.text, !groupName.isEmpty else {
                return
            }

            let group = Group(name: groupName)
            context.insert(group)

            do {
                try context.save()
                self.groupDidAddSubject.onNext(())
            } catch {
                print("Error saving group: \(error)")
            }
        }

        self.inputTextField.text = nil
        self.dismiss(animated: true)
    }

}
