//
//  OpenGraphData.swift
//  KioClip
//
//  Created by 高橋和 on 2025/10/27.
//

import Foundation
import SwiftData

@Model
final class OpenGraphData {
    var title: String?
    var imageURLString: String?
    
    var article: Article?
    
    init(title: String?, imageURLString: String?) {
        self.title = title
        self.imageURLString = imageURLString
    }
}
