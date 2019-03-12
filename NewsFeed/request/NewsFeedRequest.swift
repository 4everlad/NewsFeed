//
//  NewsFeedRequest.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 06/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation
import UIKit

class NewsFeedRequest {
    
    static let shared = NewsFeedRequest()
    
    let queue = DispatchQueue.global(qos: .utility)
    
    func requestNews(searchText: String, completion: @escaping ([ArticleModel]?, Error?)->()) {
        
        let url = URL(string: "https://newsapi.org/v2/everything?q=\(searchText)&apiKey=b59bc1f13f884301a259ebc4a7c68af2")!
        queue.async {
            let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    let data = data
                    else {
                        print("No connection")
                        completion(nil, error)
                        return
                }
                
                print("quote: \(data)")
                if let newsFeed = self.parseNews(data: data) {
                    if newsFeed.count > 0 {
                        completion(newsFeed, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, nil)
                }
            }
            dataTask.resume()
        }
        
    }
    
    
    func parseNews(data: Data) -> [ArticleModel]? {
        
        var newsFeed: [ArticleModel]!
        
        struct ParseNews: Codable {
            var articles: [ParseArticle]?
        }
        
        struct ParseArticle: Codable {
            var urlToImage: String?
            var title: String?
            var publishedAt: String?
            var description: String?
            var url: String?
        }
        
        do {
            let response = try JSONDecoder().decode(ParseNews.self, from: data)
            
            if let articles = response.articles {
                
                newsFeed = [ArticleModel]()
                
                for article in articles {
                    let articleForNewsFeed = ArticleModel()
                    
                    if let title = article.title {
                        articleForNewsFeed.title = title
                    }
                    
                    if let urlToImage = article.urlToImage {
                        articleForNewsFeed.urlToImage = urlToImage
                        articleForNewsFeed.imageName = String(articleForNewsFeed.hashValue)
                    } else {
                        articleForNewsFeed.urlToImage = nil

                    }
                    
                    if let publishedAt = article.publishedAt {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
                        articleForNewsFeed.publishedAt = dateFormatter.date(from:publishedAt)
                    }
                    
                    if let description = article.description {
                        articleForNewsFeed.description = description
                    }
                    
                    if let url = article.url {
                        articleForNewsFeed.url = url
                    }
                    
                    
                    newsFeed.append(articleForNewsFeed)
                    
                }
                
                
            }
            
        } catch {
            print("JSON parsing error: " + error.localizedDescription)

            return nil
        }
        
        
        newsFeed = newsFeed.sorted(by: {
            $0.publishedAt!.compare($1.publishedAt!) == .orderedDescending
        })
        
        return newsFeed
    }
    
    
    init() {

    }
}
