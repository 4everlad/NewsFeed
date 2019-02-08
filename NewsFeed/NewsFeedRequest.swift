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
    
    var dataManager = DataManager.shared
    
    var delegate: NewsFeedUpdateDelegate!
    
    var newsFeed: [ArticleModel]! {
        didSet {
            delegate.updateTableView()
        }
    }
    
    func requestNews() {
        
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=b59bc1f13f884301a259ebc4a7c68af2")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("No connection")
                    if let cashedNewsFeed = self.dataManager.readNews() {
                        self.newsFeed = cashedNewsFeed
                    } else {
                        print("No cashed NewsFeed")
                    }
                    return
            }
            print("quote: \(data)")
            self.parseNews(data: data)
        }
        
        dataTask.resume()
    }
    
    
    func parseNews(data: Data) {
        
        
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
                
                for (index, article) in articles.enumerated() {
                    var articleForNewsFeed = ArticleModel()
                    
                    if let title = article.title {
                        articleForNewsFeed.title = title
                    }
                    
                    if let urlToImage = article.urlToImage {
                        downloadImage(from: urlToImage, completion: { downloadedImage in
                            articleForNewsFeed.image = downloadedImage
//                            self.tableView.reloadData()
                        } )
                    } else {
                        articleForNewsFeed.image = UIImage(named: "No-images-placeholder")
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
                
                var tempArray = [ArticleModel]()
                
                for index in 0...4 {
                    tempArray.append(newsFeed[index])
                }
                
                dataManager.saveNews(for: tempArray)
                
            }
            
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
        
    }
    
    
    func downloadImage(from url: String, completion: @escaping(UIImage)->()) {
        
        if let imageUrl = URL(string: url) {
            print("Image Download Started")
            var image: UIImage?
            getData(from: imageUrl, completion: { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? imageUrl.lastPathComponent)
                print("Image Download Finished")
                image = UIImage(data: data)
                completion(image!)
                
            })
            print("b")
        } else {
            print("URL is gone")
            let image = UIImage(named: "No-images-placeholder")
            completion(image!)
        }
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> (Void)) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        
    }
    
    init() {
        newsFeed = [ArticleModel]()
        
        requestNews()
    }
}
