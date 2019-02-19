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

    
//    var delegate: NewsFeedUpdateDelegate!
    
//    var newsFeed: [ArticleModel]! {
//        didSet {
//            delegate.updateTableView()
//            var numberCashedNewsFeed: Int!
//            let numberNewsFeed = newsFeed.count
//            if numberNewsFeed > 5 {
//                var isReadyForSaving = true
//                for index in 1...5 {
//                    if newsFeed[index].image == nil {
//                        isReadyForSaving = false
////                        break
//                    }
//                }
//                if isReadyForSaving == true {
//                    var cashedNewsFeed = [ArticleModel]()
//                    for index in 1...5 {
//                        cashedNewsFeed.append(newsFeed[index])
//                    }
//                    self.dataManager.saveNews(for: cashedNewsFeed)
//                }
//
//            }
//        }
//    }
    
    func requestNews(keyword: String, completion: @escaping ([ArticleModel]?, Error?)->()) {
        
        let url = URL(string: "https://newsapi.org/v2/everything?q=\(keyword)&apiKey=b59bc1f13f884301a259ebc4a7c68af2")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("No connection")
//                    if let cashedNewsFeed = self.dataManager.readNews() {
//                        self.newsFeed = cashedNewsFeed
//                    } else {
//                        print("No cashed NewsFeed")
//                    }
                    completion(nil, error)
                    return
            }
            print("quote: \(data)")
            if let newsFeed = self.parseNews(data: data) {
                completion(newsFeed, nil)
            } else {
                completion(nil, nil)
            }
        }
        
        dataTask.resume()
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
                        downloadImage(from: urlToImage, completion: { downloadedImage in
                            articleForNewsFeed.image = downloadedImage
//                            self.delegate.updateTableView()
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
                
                
            }
            
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
//            completion(nil, error)
            return nil
        }
        
        
//        var isParsed = false
        
//        while(!isParsed) {
//            for article in newsFeed {
//                isParsed = true
//                if article.image == nil {
//                    isParsed = false
//                    break
//                }
//            }
//        }
        
        return newsFeed
    }
    
    
    func downloadImage(from url: String, completion: @escaping(UIImage)->()) {
        
        if let imageUrl = URL(string: url) {
            print("Image Download Started")
            var image: UIImage?
            getData(from: imageUrl, completion: { data, response, error in
                guard let data = data, error == nil else { let image = UIImage(named: "No-images-placeholder")
                    completion(image!)
                    return }
                print(response?.suggestedFilename ?? imageUrl.lastPathComponent)
                print("Image Download Finished")
                image = UIImage(data: data)
                if let parsedImage = image {
                    completion(parsedImage)
                } else {
                    let image = UIImage(named: "No-images-placeholder")
                    completion(image!)
                }
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
//        newsFeed = [ArticleModel]()
        
//        requestNews()
    }
}
