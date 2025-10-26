import SwiftData
import UIKit

class ArticleListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            ArticleTableViewCell.self, forCellReuseIdentifier: "ArticleTableViewCell")
        return tableView
    }()

    private lazy var context: ModelContext = {
        return PersistenceController.shared.mainContext
    }()

    private let addButton = AddButton()

    private let listTitle: String
    private var articles: [Article] = []

    private let searchController = UISearchController(searchResultsController: nil)

    // 統合された初期化
    init(title: String, articles: [Article] = []) {
        self.listTitle = title
        self.articles = articles
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        title = listTitle

        setupSearchController()
        setupUI()
        setupDataSource()
        fetchArticles()
    }

    private func fetchArticles() {
        // FetchDescriptor(取得したいデータの注文書のようなもの)を作成
        // savedDateの降順（新しい順）でソート
        let descriptor = FetchDescriptor<Article>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            // Contextにリクエストを投げて、データを取得
            let fetchedArticles = try context.fetch(descriptor)
            self.articles = fetchedArticles
            print("✅ \(self.articles.count)件の記事を取得しました。")
            tableView.reloadData()
        } catch {
            print("❌ 記事の取得に失敗しました: \(error)")
        }
    }

    private func setupSearchController() {
        searchController.searchBar.placeholder = "検索"

        navigationItem.searchController = searchController

        // 5. 常に表示したければ false にする (オプション)
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            addButton.trailingAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
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

// MARK: - UITableViewDataSource
extension ArticleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath)
            as! ArticleTableViewCell
        cell.configure(with: articles[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
// Cellがタップされたときの処理を加えるための拡張
extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let article = articles[indexPath.row]
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url)
        }
    }
}
