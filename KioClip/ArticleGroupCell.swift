import UIKit

class ArticleGroupCell: UICollectionViewCell {

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

    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
                self.contentView.layer.borderColor = UIColor.systemGreen.cgColor
                self.contentView.layer.borderWidth = 2

            } else {
                self.contentView.backgroundColor = .secondarySystemBackground
                self.contentView.layer.borderWidth = 0
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // --- 1. 影（シャドウ）の設定 ---
        // 影は「セル本体(self.layer)」に設定
        backgroundColor = .clear  // ⬅︎ セル自体は透明に
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false  // ⬅︎ 影を外にはみ出させる

        // --- 2. 見た目の設定 ---
        // 見た目は "contentView.layer" に設定
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true  // ⬅︎ これで contentView が角丸になる

        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),

            countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
        ])
    }

    func configure(group: Group) {
        titleLabel.text = group.name
        countLabel.text = "記事数: \(group.articles.count)"
    }
}
