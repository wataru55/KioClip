import UIKit
import SwiftData
import RxSwift
import RxCocoa

class ArticleGroupViewController: UIViewController {
    private var groups: [Group] = []
    let navTitle: String
    
    private let articleGroupView = ArticleGroupView()
    private let dataService = GroupDataService()
    private let dataSource = GroupDataSource()
    
    private var disposeBag = DisposeBag()
    
    private let groupsDidSelectSubject = PublishSubject<[Group]>()
    var groupsDidSelect: Observable<[Group]>
    
    var isForSelection: Bool = false
    
    init(navTitle: String) {
        self.navTitle = navTitle
        self.groupsDidSelect = groupsDidSelectSubject.asObservable()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        groupsDidSelectSubject.onCompleted()
    }
    
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
        title = navTitle
        
        setupDataSource()
        
        if isForSelection {
            setupForSelection()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    private func setupForSelection() {
        // CollectionViewで "複数選択" を許可
        articleGroupView.collectionView.allowsMultipleSelection = true
        
        let doneButton = UIBarButtonItem(
            title: "完了",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        self.navigationItem.rightBarButtonItem = doneButton
        
        let cancelButton = UIBarButtonItem(
            title: "キャンセル",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    @objc private func addButtonTapped() {
        let modalVC = ModalViewController(type: ModalViewControllerType.group)
        modalVC.groupDidAdd
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.fetchGroups()
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
    
    @objc private func doneButtonTapped() {
        // (a) 現在選択されている全ての "IndexPath" を取得
        guard let selectedIndexPaths = articleGroupView.collectionView.indexPathsForSelectedItems,
              !selectedIndexPaths.isEmpty
        else {
            self.dismiss(animated: true)
            return
        }
        
        // (b) "IndexPath" の配列を "Group" の配列に変換
        let selectedGroups = selectedIndexPaths.map { indexPath in
            self.groups[indexPath.item]
        }
        
        self.groupsDidSelectSubject.onNext(selectedGroups)
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
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
        
        print("👉 タップされたグループ: (\(selectedGroup.name), ID: \(selectedGroup.persistentModelID.hashValue))")
        
        if !isForSelection {
            let groupArticleListVC = ArticleListViewController(title: selectedGroup.name, selectedGroup: selectedGroup)
            navigationController?.pushViewController(groupArticleListVC, animated: true)
        }
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
