import Kingfisher
import UIKit

class ArticleTableViewCell: UITableViewCell {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    private let ogpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill  // 画像の表示モード
        imageView.clipsToBounds = true  // 角丸などのため
        imageView.layer.cornerRadius = 4
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        return label
    }()

    private let urlHostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let bottomRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        bottomRowStackView.addArrangedSubview(urlHostLabel)
        bottomRowStackView.addArrangedSubview(dateLabel)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(bottomRowStackView)

        contentView.addSubview(ogpImageView)
        contentView.addSubview(textStackView)

        NSLayoutConstraint.activate([
            ogpImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            ogpImageView.widthAnchor.constraint(equalToConstant: 140),
            ogpImageView.heightAnchor.constraint(equalToConstant: 80),
            ogpImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            ogpImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            textStackView.leadingAnchor.constraint(
                equalTo: ogpImageView.trailingAnchor, constant: 8),
            textStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -8),
            textStackView.topAnchor.constraint(equalTo: ogpImageView.topAnchor, constant: 4),
            textStackView.bottomAnchor.constraint(equalTo: ogpImageView.bottomAnchor, constant: -4),

        ])
    }

    func configure(with article: Article) {
        if let urlString = article.ogp?.imageURLString, let url = URL(string: urlString) {
            ogpImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))],
            )
        } else {
            ogpImageView.image = UIImage(systemName: "network")
        }

        titleLabel.text = article.ogp?.title ?? article.url

        if let articleURL = URL(string: article.url) {
            urlHostLabel.text = articleURL.host ?? ""
        } else {
            urlHostLabel.text = ""  // 念のためのフォールバック
        }

        dateLabel.text = "保存: \(Self.dateFormatter.string(from: article.createdAt))"
    }
}
