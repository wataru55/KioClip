//
//  ArticleGroupView.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/04.
//

import UIKit

final class ArticleGroupView: UIView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            ArticleGroupCell.self, forCellWithReuseIdentifier: "ArticleGroupCell")
        return collectionView
    }()
    
    let addButton = AddButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .systemBackground

        self.addSubview(collectionView)
        self.addSubview(addButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor),

            addButton.trailingAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

