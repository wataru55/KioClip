//
//  ArticleListDataSource.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/27.
//

import UIKit

// UITableViewDataSourceを専門に担うクラス
// NSObjectの継承は、UITableViewDataSourceがobjcプロトコルであるため必要
final class ArticleListDataSource: NSObject, UITableViewDataSource {
    // Controllerからデータを受け取るためのプロパティ
    var articles: [Article] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath)
            as! ArticleTableViewCell
        
        let article = articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
}
