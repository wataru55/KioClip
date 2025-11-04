import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemGreen
        tabBar.unselectedItemTintColor = .systemGray
    }

    private func setupViewControllers() {
        // グループタブ
        let groupVC = ArticleGroupViewController()
        // グループタブをNavigationControllerでラップ
        let groupNavVC = UINavigationController(rootViewController: groupVC)
        groupNavVC.tabBarItem = UITabBarItem(
            title: "グループ",
            image: UIImage(systemName: "folder"),
            selectedImage: UIImage(systemName: "folder.fill")
        )

        // 全記事タブ
        let allArticles = generateMockAllArticles()
        let articleListVC = ArticleListViewController(title: "一覧", articles: allArticles)
        let articleNavVC = UINavigationController(rootViewController: articleListVC)
        articleNavVC.tabBarItem = UITabBarItem(
            title: "一覧",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle")
        )

        // タブを設定
        viewControllers = [groupNavVC, articleNavVC]
    }

    private func generateMockAllArticles() -> [Article] {
        let groups = ["Swift", "React", "データベース", "アルゴリズム", "UI/UX", "機械学習"]
        var allArticles: [Article] = []

        for (_, group) in groups.enumerated() {
            let mockTitles = [
                "\(group)の基礎知識",
                "\(group)でよくあるエラーと解決方法",
                "\(group)のベストプラクティス",
                "\(group)の最新機能について",
                "\(group)を使った実装例",
            ]

            for (articleIndex, _) in mockTitles.enumerated() {
                let article = Article(
                    url: "https://example.com/\(group.lowercased())/article\(articleIndex + 1)",
                )
                allArticles.append(article)
            }
        }

        return allArticles
    }
}
