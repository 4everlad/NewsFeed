//
//  DataManager.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 17/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    
//    var dataManager = DataManager.shared
    
    var newsFeedRequest = NewsFeedRequest.shared
    
    var delegate: NewsFeedUpdateDelegate!
    
    var newsFeed: [ArticleModel]!
    
    var cashedNewsFeeds: [String : [ArticleModel]]!
    
    
    
    func performSearch(keyword: String, completion: ((_ success: Bool, _ error: Error?) -> Void)? ) {
        newsFeedRequest.requestNews(keyword: keyword, completion: { parsedNewsFeed, error in
            if error == nil {
                if let newsFeed = parsedNewsFeed {
                    self.newsFeed = newsFeed
                    //                    saveNewsSearch(search: String, news: [ArticleModel])
                    completion!(true, nil)
                } else {
                    completion!(false, nil)
                }
            } else {
                completion!(false, error)
            }
        })
    }
    
    func saveNewsSearch(search: String, news: [ArticleModel]) {
        if cashedNewsFeeds.count < 5 {
            cashedNewsFeeds[search] = news
        } else {
            
        }
    }
    
    func loadCashedNewsFeeds() {
        
    }
    
    init() {
        newsFeed = [ArticleModel]()
        cashedNewsFeeds = [:]
//        cashedNewsFeeds = [:]
//        cashedNewsFeed = [ArticleModel]()
        loadCashedNewsFeeds()
    }
}
