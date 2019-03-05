//
//  DataManager.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 17/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation
import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    var coreDataManager = CoreDataManager.shared
    
    var newsFeedRequest = NewsFeedRequest.shared
    
    var imageRequest = ImageRequest.shared
    
    var imageFileManager = ImageFileManager.shared
    
    var delegate: NewsFeedUpdateDelegate!
    
    var newsFeed: [ArticleModel]!

    
    let mySerialQueue = DispatchQueue(label: "com.NewsFeed.mySerial")
    
    
    var cashedNewsFeeds: [SearchRequestModel : [ArticleModel]]!
    
    func performSearch(searchText: String, completion: ((_ success: Bool, _ error: Error?) -> Void)? ) {
        newsFeedRequest.requestNews(searchText: searchText, completion: { parsedNewsFeed, error in
            if error == nil {
                if let newsFeed = parsedNewsFeed {
                    
                    // добавить getimages(for newsFeed)
                    let newsFeedWithImages = self.setImages(for: newsFeed)
                    self.updateSearchRequests(searchRequest: searchText, newsFeed: newsFeedWithImages)
                    self.newsFeed = newsFeedWithImages
                    completion!(true, nil)
                    
                } else {
                    completion!(false, nil)
                }
            } else {
                let searchRequest = SearchRequestModel(text: searchText)
                
                if self.cashedNewsFeeds[searchRequest] != nil {
                    self.newsFeed = self.cashedNewsFeeds[searchRequest]
                }
                completion!(false, error)
            }
        })
    }
    
    func updateSearchRequests(searchRequest: String, newsFeed: [ArticleModel]) {
        
        let newSearchRequest = SearchRequestModel(text: searchRequest)
        
        if cashedNewsFeeds[newSearchRequest] != nil {
            
            mySerialQueue.sync {
                coreDataManager.deleteNews(for: newSearchRequest.text)
            }
            cashedNewsFeeds[newSearchRequest] = newsFeed
            mySerialQueue.sync {
                coreDataManager.saveNews(for: newSearchRequest, with: newsFeed)
            }
            
        } else {
            if cashedNewsFeeds.count >= 5 {
                let searchRequests = Array(cashedNewsFeeds.keys)
                let sortedSearchRequests = searchRequests.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                let lastSearchRequest = sortedSearchRequests.last
                let oldNewsFeed = cashedNewsFeeds[lastSearchRequest!]
                
                for article in oldNewsFeed! {
                    if let imageName = article.imageName {
                        imageFileManager.deleteImage(name: imageName, completion: nil)
                    }
                }
                coreDataManager.deleteNews(for: lastSearchRequest!.text)
                cashedNewsFeeds[lastSearchRequest!] = nil
                cashedNewsFeeds[newSearchRequest] = newsFeed
                coreDataManager.saveNews(for: newSearchRequest, with: newsFeed)
                
            } else {
                cashedNewsFeeds![newSearchRequest] = newsFeed
                coreDataManager.saveNews(for: newSearchRequest, with: newsFeed)
                
            }
        }
    }
    

    
    func setImages(for newsFeed: [ArticleModel]) -> [ArticleModel] {
        
        for article in newsFeed {
            if let urlToImage = article.urlToImage {
                imageRequest.downloadImage(from: urlToImage, completion: { image in
                    article.image = image
                    self.imageFileManager.saveImage(name: article.imageName!, image: article.image!, completion: nil)
                })
            } else {
                let image = UIImage(named: "No-images-placeholder")
                article.image = image
                imageFileManager.saveImage(name: article.imageName!, image: article.image!, completion: nil)
            }
        }
        
        return newsFeed
    }
    

    
    func getCashedNewsFeeds() -> [SearchRequestModel: [ArticleModel]] {
        
        var newsFeeds: [SearchRequestModel : [ArticleModel]]!
        
        newsFeeds = [:]
        
        if let articles = coreDataManager.readNews() {
            
            if articles.count != 0 {
                var searchRequests = [SearchRequestModel]()
                
                for article in articles {
                    var isFound = false
                    for searchRequest in searchRequests {
                        if searchRequest.text == article.searchRequest {
                            isFound = true
                            break
                        }
                    }
                    if !isFound {
                        let uniqueSearchRequest = SearchRequestModel(text: article.searchRequest!)
                        uniqueSearchRequest.date = article.requestDate!
                        searchRequests.append(uniqueSearchRequest)
                    }
                }
                
                for searchRequest in searchRequests {
                    let filteredArticles = articles.filter { $0.searchRequest == searchRequest.text }
                    
                    var newsFeed = [ArticleModel]()
                    
                    for article in filteredArticles {
                        let articleToAdd = ArticleModel()
                        articleToAdd.title = article.title
                        articleToAdd.description = article.newsDescription
                        articleToAdd.publishedAt = article.publishedAt
                        articleToAdd.url = article.url

                        if let imageName = article.imageName {
                            articleToAdd.image = imageFileManager.loadImage(name: imageName, completion: nil)
                        } else {
                            articleToAdd.image = UIImage(named: "No-images-placeholder")
                        }
                        
                        newsFeed.append(articleToAdd)
                    }
                    
                    newsFeed = newsFeed.sorted(by: {
                        $0.publishedAt!.compare($1.publishedAt!) == .orderedDescending
                    })
                    
                    newsFeeds[searchRequest] = newsFeed
                }
            } else {
                newsFeeds = [:]
            }
        } else {
            newsFeeds = [:]
        }
    
        return newsFeeds
        
    }
    
    init() {
        newsFeed = [ArticleModel]()
        cashedNewsFeeds = getCashedNewsFeeds()
    }
}
