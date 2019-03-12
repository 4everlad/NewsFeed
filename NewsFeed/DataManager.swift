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
    
    var numberSearchRequests: Int!
    
    var coreDataManager = CoreDataManager.shared
    
    var newsFeedFetcher = NewsFeedFetcher.shared
    
//    var imageRequest = ImageRequest.shared
    
//    var imageFileManager = ImageFileManager.shared
    
    var delegate: NewsFeedUpdateDelegate!
    
    var newsFeed: [ArticleModel]!
    
    var searchRequest: SearchRequestModel?

    let queue = DispatchQueue.global(qos: .utility)
    
//    let mySerialQueue = DispatchQueue(label: "com.NewsFeed.mySerial", qos: .userInitiated, attributes: .concurrent)
    
    var cashedNewsFeeds: [SearchRequestModel : [ArticleModel]]!
    
    func performSearch(searchText: String, completion: ((_ success: Bool, _ error: Error?) -> Void)? ) {
        newsFeedFetcher.requestNews(searchText: searchText, completion: { parsedNewsFeed, error in
            if error == nil {
                if let newsFeed = parsedNewsFeed {
                    
//                    self.searchRequest = SearchRequestModel(text: searchText)
                    // добавить getimages(for newsFeed)
                    let newsFeedWithImages = self.setImages(for: newsFeed)
//                    self.updateSearchRequests(searchRequest: self.searchRequest!, newsFeed: newsFeedWithImages)
                    self.newsFeed = newsFeedWithImages
                    completion!(true, nil)
                    
                } else {
                    completion!(false, nil)
                }
            } else {
//                self.searchRequest = SearchRequestModel(text: searchText)
                
                if self.cashedNewsFeeds[self.searchRequest!] != nil {
                    self.newsFeed = self.cashedNewsFeeds[self.searchRequest!]
                }
                completion!(false, error)
            }
        })
    }
    
    
    func updateSearchRequests(searchRequest: SearchRequestModel, newsFeed: [ArticleModel]) {
        
        let newSearchRequest = searchRequest
        
        if cashedNewsFeeds[newSearchRequest] != nil {

            self.coreDataManager.deleteNews(for: newSearchRequest.text)

            cashedNewsFeeds[newSearchRequest] = newsFeed
            queue.async {
                self.coreDataManager.saveNews(for: newSearchRequest, with: newsFeed)
                self.saveImages(for: newsFeed)
            }
            
        } else {
            if cashedNewsFeeds.count >= numberSearchRequests {
                let searchRequests = Array(cashedNewsFeeds.keys)
                let sortedSearchRequests = searchRequests.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                let lastSearchRequest = sortedSearchRequests.last
                let oldNewsFeed = cashedNewsFeeds[lastSearchRequest!]
                
                for article in oldNewsFeed! {
                    if let imageName = article.imageName {
                        let imageFileManager = ImageFileManager()
                        imageFileManager.deleteImage(name: imageName, completion: nil)
                    }
                }
                queue.async {
                    self.coreDataManager.deleteNews(for: lastSearchRequest!.text)
                }
                cashedNewsFeeds[lastSearchRequest!] = nil
                cashedNewsFeeds[newSearchRequest] = newsFeed
                queue.async {
                    self.coreDataManager.saveNews(for: newSearchRequest, with: newsFeed)
                }
                queue.async {
                    self.saveImages(for: newsFeed)
                }
                
            } else {
                cashedNewsFeeds![newSearchRequest] = newsFeed
                queue.async {
                    self.coreDataManager.saveNews(for: newSearchRequest, with: newsFeed)
                }
                queue.async {
                    self.saveImages(for: newsFeed)
                }
            }
        }
    }
    
    func saveImages(for newsFeed: [ArticleModel]) {
        for article in newsFeed {
            if let imageName = article.imageName {
                if let image = article.image {
                    let imageFileManager = ImageFileManager()
                    imageFileManager.saveImage(name: imageName, image: image, completion: nil)
                }
            }
        }
    }
    
    func setImages(for newsFeed: [ArticleModel]) -> [ArticleModel] {
        
        for article in newsFeed {
            if let urlToImage = article.urlToImage {
                let imageFetcher = ImageFetcher()
                imageFetcher.downloadImage(from: urlToImage, completion: { image in
                    article.image = image
//                    self.imageFileManager.saveImage(name: article.imageName!, image: article.image!, completion: nil)
                })
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
                            let imageFileManager = ImageFileManager()
                            articleToAdd.image = imageFileManager.loadImage(name: imageName, completion: nil)
                        } else {
                            articleToAdd.image = nil
//                            articleToAdd.image = UIImage(named: "No-images-placeholder")
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
        numberSearchRequests = 5
    }
}
