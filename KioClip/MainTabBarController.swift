import UIKit

class MainTabBarController: UITabBarController {

    private var lastObservedModalState: ModalPresentationState?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()

        subscribeToStore()
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemGreen
        tabBar.unselectedItemTintColor = .systemGray
    }

    // MARK: - Redux Subscription
    private func subscribeToStore() {
        // 最初に現在の状態を記憶しておく
        lastObservedModalState = mainStore.state.modalPresentation

        // Storeに「状態が変わったら、この中の処理を呼び出せ」と登録（Subscribe）する
        mainStore.subscribe { [weak self] in
            guard let self = self else { return }

            // UIの更新は必ずメインスレッドで行うのがお作法じゃ
            DispatchQueue.main.async {
                self.handleModalPresentation(newState: mainStore.state.modalPresentation)
            }
        }
    }

    private func handleModalPresentation(newState: ModalPresentationState) {
        // 状態が前回観測した時から変化していなければ、何もしない
        guard newState != self.lastObservedModalState else { return }

        // 現在、何らかのViewControllerが表示されているか（モーダルが表示中か）
        let isModalPresented = self.presentedViewController != nil

        // [表示]
        if newState.isPresented, !isModalPresented {
            guard let modalType = newState.modalType else { return }
            self.presentModal(type: modalType)
        }
        // [非表示]
        else if !newState.isPresented, isModalPresented {
            self.dismiss(animated: true, completion: nil)
        }

        // 最後に観測した状態を、今の最新の状態に更新する
        self.lastObservedModalState = newState
    }

    private func presentModal(type: ModalViewControllerType) {
        let modalVC = ModalViewController(type: type)
        let navVC = UINavigationController(rootViewController: modalVC)

        if let sheet = navVC.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom(
                identifier: .init("small")
            ) { _ in return 200 }
            sheet.detents = [smallDetent]
            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(navVC, animated: true, completion: nil)
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
        let articleListVC = ArticleListViewController(title: "一覧", articles: [])
        let articleNavVC = UINavigationController(rootViewController: articleListVC)
        articleNavVC.tabBarItem = UITabBarItem(
            title: "一覧",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle")
        )

        // タブを設定
        viewControllers = [groupNavVC, articleNavVC]
    }
}
