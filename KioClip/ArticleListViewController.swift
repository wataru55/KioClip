import SwiftData
import UIKit
import RxSwift
import RxCocoa

class ArticleListViewController: UIViewController {
    private let listTitle: String
    private var articles: [Article] = []
    private let searchController = UISearchController(searchResultsController: nil)

    private let articleListView = ArticleListView()
    private let dataService = ArticleDataService()
    private let dataSource = ArticleListDataSource()
    
    private let disposeBag = DisposeBag()
    
    private var isSyncingOGPs = false
    
    private var selectedArticle: Article?
    private var selectedGroup: Group?

    // 統合された初期化
    init(title: String, articles: [Article] = [], selectedGroup: Group? = nil) {
        self.listTitle = title
        self.articles = articles
        self.selectedGroup = selectedGroup
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = articleListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        articleListView.addButton.addTarget(
            self, action: #selector(addButtonTapped), for: .touchUpInside)
        title = listTitle

        setupSearchController()
        setupDataSource()
        fetchArticles()
    }
    
    private func reloadTableView() {
        self.dataSource.articles = self.articles
        self.articleListView.tableView.reloadData()
    }

    private func fetchArticles() {
        self.articles = dataService.fetchArticles(group: selectedGroup)
        reloadTableView()
        triggerOGPSync()
    }

    private func triggerOGPSync() {
        guard !isSyncingOGPs else {
            return
        }
        // OGPがない記事だけを対象にする
        let articlesToFetch = self.articles.filter { $0.ogp == nil }
        
        guard !articlesToFetch.isEmpty else {
            print("ℹ️ OGP sync: 全てのOGPはキャッシュ済みです")
            return
        }
        print("ℹ️ OGP sync: \(articlesToFetch.count)件のOGP同期タスクを開始します...")
        
        isSyncingOGPs = true

        Task {
            for article in articlesToFetch {
                try? Task.checkCancellation()
                await dataService.fetchAndCacheOGP(articleID: article.id)
            }
            
            let latestArticles = dataService.fetchArticles()
            
            await MainActor.run {
                self.isSyncingOGPs = false
                self.articles = latestArticles
                reloadTableView()
            }
        }
    }

    private func setupSearchController() {
        searchController.searchBar.placeholder = "検索"

        navigationItem.searchController = searchController

        // 5. 常に表示したければ false にする (オプション)
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupDataSource() {
        articleListView.tableView.dataSource = self.dataSource
        articleListView.tableView.delegate = self
    }

    @objc private func addButtonTapped() {
        let modalVC = ModalViewController(type: ModalViewControllerType.article)
        
        modalVC.articleDidAdd
            .subscribe(onNext: { [weak self] _ in
                self?.fetchArticles()
            })
            .disposed(by: disposeBag)
        
        let navVC = UINavigationController(rootViewController: modalVC)

        if let sheet = navVC.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom(
                identifier: .init("small")
            ) { context in
                // ここで好きな高さを返す
                return 200
            }
            sheet.detents = [smallDetent]
            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }

        present(navVC, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
// Cellがタップされたときの処理を加えるための拡張
extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        articleListView.tableView.deselectRow(at: indexPath, animated: true)

        let article = articles[indexPath.row]
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url)
        }
    }
    
    //右カラスワイプした時の処理
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let alertAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { (_, _, completionHandler) in
            print("通知を設定したよ")
            completionHandler(true)
        }
        
        alertAction.image = UIImage(systemName: "bell.fill")
        alertAction.backgroundColor = .systemGreen
        
        let groupAction = UIContextualAction(
            style: .normal,
            title: nil) { _, _, completionHandler in
                
                self.selectedArticle = self.articles[indexPath.row]
                let groupVC = ArticleGroupViewController(navTitle: "グループを選択")
                groupVC.isForSelection = true
                groupVC.delegete = self
                
                let navVC = UINavigationController(rootViewController: groupVC)
                
                self.present(navVC, animated: true)
                completionHandler(true)
            }
        
        groupAction.image = UIImage(systemName: "list.bullet")
        
        let configuration = UISwipeActionsConfiguration(actions: [alertAction, groupAction])
        return configuration
    }
    
    //左からスワイプした時の処理
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil,
        ) { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false) // 失敗を通知
                return
            }
            
            let articleToDelete = self.articles[indexPath.row]
            dataService.deleteArticle(article: articleToDelete)
            
            self.articles.remove(at: indexPath.row)
            self.dataSource.articles = self.articles
            self.articleListView.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            print("記事を削除しました。")
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

extension ArticleListViewController: ArticleGroupViewControllerDelegate {
    func didSelect(group: Group) {
        print("「\(group.name)」が選択されて戻ってきたぞ")
        
        guard let selectedArticle = self.selectedArticle else { return }
        selectedArticle.group = group
        
        dataService.updateArticle(article: selectedArticle)
        
        self.selectedArticle = nil
    }
}
