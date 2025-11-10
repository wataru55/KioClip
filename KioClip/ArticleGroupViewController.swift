import UIKit

class ArticleGroupViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            ArticleGroupCell.self, forCellWithReuseIdentifier: "ArticleGroupCell")
        return collectionView
    }()

    private let addButton = AddButton()

    // 仮のグループデータ
    var groups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        setupUI()
        setupDataSource()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "グループ"

        view.addSubview(collectionView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            addButton.trailingAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupDataSource() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @objc private func addButtonTapped() {
        let modalVC = ModalViewController(type: ModalViewControllerType.group)
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

// MARK: - UICollectionViewDataSource
extension ArticleGroupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return groups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleGroupCell", for: indexPath) as! ArticleGroupCell

        cell.configure(with: groups[indexPath.item].name)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ArticleGroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.frame.width - 48) / 2  // 2列表示、マージン考慮
        return CGSize(width: width, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGroup = groups[indexPath.item]
        let groupArticleListVC = ArticleListViewController(title: selectedGroup.name)
        navigationController?.pushViewController(groupArticleListVC, animated: true)
    }
}
