//
//  DataManager.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 17/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation

class DataManager {
    
    var dataManager = CoreDataManager.shared
    
    var newsFeedRequest = NewsFeedRequest.shared
    
    var newsFeed: [ArticleModel]!
    
    var cashedNewsFeed: [ArticleModel]!
    
    func performSearch() {
        
    }
    
}
