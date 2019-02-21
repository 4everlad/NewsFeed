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
    
    var newsFeed: [ArticleModel]! {
            didSet {
                delegate.updateTableView()
        }
    }
    
//    var search
    
//    let mySerialQueue = DispatchQueue(label: "com.NewsFeed.mySerial")
    
    var cashedNewsFeeds: [SearchRequestModel : [ArticleModel]]!
    
    
    func performSearch(searchText: String, completion: ((_ success: Bool, _ error: Error?) -> Void)? ) {
        newsFeedRequest.requestNews(searchText: searchText, completion: { parsedNewsFeed, error in
            if error == nil {
                if let newsFeed = parsedNewsFeed {
        
                    self.newsFeed = newsFeed
                    self.saveNewsSearch(search: searchText, news: newsFeed)
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
            let searchRequest = SearchRequestModel(text: search)
            printCashedHash(search: searchRequest)
            cashedNewsFeeds![searchRequest] = news
        } else {
            
        }
    }
    
    func loadCashedNewsFeeds() {
        
    }
    
    func printCashedHash(search: SearchRequestModel) {
        print("hashValue:\(search.hashValue)")
    }
    
    init() {
        newsFeed = [ArticleModel]()
        cashedNewsFeeds = [:]
//        cashedNewsFeeds = [:]
//        cashedNewsFeed = [ArticleModel]()
        loadCashedNewsFeeds()
    }
}
