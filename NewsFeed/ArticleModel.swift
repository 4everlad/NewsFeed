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
    var publishedAt: Date?
    var title: String?
    var description: String?
    var url: String?
    var isSeen = false
    
    init() {
        publishedAt = Date()
    }
}
