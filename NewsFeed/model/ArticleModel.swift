//
//  ArticleModel.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 07/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit
import Foundation

class ArticleModel {
    var image: UIImage?
    var imageName: String?
    var publishedAt: Date?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var isSeen = false
    
    init() {
        publishedAt = Date()
    }
}

extension ArticleModel: Equatable {
    static func == (lhs: ArticleModel, rhs: ArticleModel) -> Bool {
        return lhs.title == rhs.title && lhs.publishedAt == rhs.publishedAt
    }
}

extension ArticleModel: Hashable {
    var hashValue: Int {
        return title.hashValue ^ publishedAt.hashValue
    }
}
