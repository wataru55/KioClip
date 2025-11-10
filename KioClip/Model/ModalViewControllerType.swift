//
//  ModalViewControllerType.swift
//  KioClip
//
//  Created by 高橋和 on 2025/11/10.
//

import Foundation

enum ModalViewControllerType {
    case group
    case article

    var navBarTitle: String {
        switch self {
        case .group:
            return "新規グループ"
        case .article:
            return "新規URL"
        }
    }

    var textFieldType: TextFieldType {
        switch self {
        case .group:
            return .group
        case .article:
            return .article
        }
    }
}
