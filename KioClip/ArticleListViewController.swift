import SwiftData
import UIKit

class ArticleListViewController: UIViewController {
    private let listTitle: String
    private var articles: [Article] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let articleListView = ArticleListView()
    private let dataService = ArticleDataService()
    private let dataSource = ArticleListDataSource()
    
    // 統合された初期化
    init(title: String, articles: [Article] = []) {
        self.listTitle = title
        self.articles = articles
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
        articleListView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        title = listTitle

        setupSearchController()
        setupDataSource()
        fetchArticles()
        
        Task {
            await syncAllOGPs()
        }
    }

    private func fetchArticles() {
        self.articles = dataService.fetchArticles()
        self.dataSource.articles = self.articles
        self.articleListView.tableView.reloadData()
    }
    
    private func syncAllOGPs() async {
        // OGPがない記事だけを対象にする
        let articlesToFetch = self.articles.filter { $0.ogp == nil }
        
        for article in articlesToFetch {
            // 1件ずつ順番に取得・保存
            await dataService.fetchAndCacheOGP(articleID: article.id)
            self.fetchArticles()
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
}
