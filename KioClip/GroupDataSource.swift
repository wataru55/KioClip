//
//  GroupDataSource.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/04.
//

import Foundation
import UIKit

final class GroupDataSource: NSObject, UICollectionViewDataSource {
    var groups: [Group] = []
    
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

        cell.configure(group: groups[indexPath.item])
        return cell
    }
}
