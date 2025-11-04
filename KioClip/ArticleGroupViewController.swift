import UIKit
import SwiftData
import RxSwift
import RxCocoa

class ArticleGroupViewController: UIViewController {
    private var groups: [Group] = []
    
    private let articleGroupView = ArticleGroupView()
    private let dataService = GroupDataService()
    private let dataSource = GroupDataSource()
    
    private var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = articleGroupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        articleGroupView.addButton.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
        title = "グループ"
        
        setupDataSource()
        fetchGroups()
    }
    
    private func fetchGroups() {
        self.groups = dataService.fetchGroups()
        self.dataSource.groups = self.groups
        self.articleGroupView.collectionView.reloadData()
    }

    private func setupDataSource() {
        articleGroupView.collectionView.dataSource = self.dataSource
        articleGroupView.collectionView.delegate = self
    }

    @objc private func addButtonTapped() {
        let modalVC = ModalViewController(type: ModalViewControllerType.group)
        modalVC.groupDidAdd
            .subscribe(onNext: { [weak self] _ in
                self?.fetchGroups()
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

// MARK: - UICollectionViewDelegateFlowLayout
extension ArticleGroupViewController: UICollectionViewDelegateFlowLayout {
    private var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    private var itemsPerRow: CGFloat { 2 }
    private var interitemSpacing: CGFloat { 16 }
    private var lineSpacing: CGFloat { 16 }
    
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let insets = self.sectionInsets
        let spacing = self.interitemSpacing
        
        // 4. 正しい幅を計算
        // (全体の幅 - 左余白 - 右余白 - (アイテム間の隙間 * 隙間の数)) / 列数
        let totalHorizontalPadding = insets.left + insets.right + (spacing * (itemsPerRow - 1))
        let width = (collectionView.frame.width - totalHorizontalPadding) / itemsPerRow
        return CGSize(width: floor(width), height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGroup = groups[indexPath.item]
        let groupArticleListVC = ArticleListViewController(title: selectedGroup.name)
        navigationController?.pushViewController(groupArticleListVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.lineSpacing
    }
}
