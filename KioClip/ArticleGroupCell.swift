import UIKit

class ArticleGroupCell: UICollectionViewCell {
    // 1：UIコンポーネントのインスタンス化
    // 2: SubViewへの追加
    // 3: Auto Layout制約の設定

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1

        addSubview(titleLabel)
        addSubview(countLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),

            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
        ])
    }

    func configure(group: Group) {
        titleLabel.text = group.name
        countLabel.text = "記事数: \(group.articles.count)"
    }
}
