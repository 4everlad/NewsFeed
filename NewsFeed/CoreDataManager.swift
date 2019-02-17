//
//  DataManager.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 07/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    var context: NSManagedObjectContext!
    
    var appDelegate: AppDelegate!
    
    static let shared = CoreDataManager()
    
    
    func readNews() -> [ArticleModel]? {
        
        var articles = [ArticleModel]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
                for article in result as! [NSManagedObject] {
                    let articleToAdd = ArticleModel()
                    articleToAdd.title = (article.value(forKey: "title") as! String)
                    articleToAdd.description = (article.value(forKey: "newsDescription") as! String)
                    articleToAdd.publishedAt = (article.value(forKey: "publishedAt") as! Date)
                    
                    if let dataImage = article.value(forKey: "image") as? Data {
                        let image = UIImage(data: dataImage)
                        articleToAdd.image = image
                    }
                    
                    articles.append(articleToAdd)
                
            }
        } catch {
            print("Failed")
        }
        
        return articles
    }
    
    
    
    func saveNews(for articles: [ArticleModel]) {
        
        if readNews() != nil {
            deleteNews()
        }
        
        for article in articles {
            let insertNewArticle = NSEntityDescription.insertNewObject(forEntityName: "Article",
                                                                            into: context) as! Article
            insertNewArticle.title = article.title
            insertNewArticle.newsDescription = article.description
            insertNewArticle.publishedAt = article.publishedAt
            insertNewArticle.url = article.url
            if let image = article.image {
                insertNewArticle.image = image.jpegData(compressionQuality: 1.0)
            }
        }
        
        performSave()

    }
    
    func deleteNews() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        
        do {
            let articles = try context.fetch(fetchRequest) as! [NSManagedObject]
            for article in articles {
                context.delete(article)
            }
            // Save Changes
            performSave()
            
        } catch {
            print("Failed")
        }
    }
    
    func performSave() {
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    init() {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        context = appDelegate.persistentContainer.viewContext
    }
    
}
