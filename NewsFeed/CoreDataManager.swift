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
    
    func readNews() -> [Article]? {

        var articles = [Article]()

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)

            articles = result as! [Article]

        } catch {
            print("Failed")
        }

        return articles
    }
    
    func saveNews(for searchRequest: SearchRequestModel, with articles: [ArticleModel]) {
        
        for article in articles {
            let insertNewArticle = NSEntityDescription.insertNewObject(forEntityName: "Article",
                                                                       into: context) as! Article
            insertNewArticle.title = article.title
            insertNewArticle.newsDescription = article.description
            insertNewArticle.publishedAt = article.publishedAt
            insertNewArticle.url = article.url
            insertNewArticle.imageName = article.imageName
            insertNewArticle.isSeen = article.isSeen
            insertNewArticle.searchRequest = searchRequest.text
            insertNewArticle.requestDate = searchRequest.date
            
        }
        
        performSave()
        
    }
    
    func deleteNews(for searchRequest: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        
        let predicate = NSPredicate(format: "searchRequest CONTAINS[C] %@", searchRequest)
        
        fetchRequest.includesPropertyValues = false
        fetchRequest.predicate = predicate
        
        do {
            let articles = try context.fetch(fetchRequest) as! [NSManagedObject]
            for article in articles {
                context.delete(article)
            }
            
            performSave()
            
        } catch {
            print("Failed")
        }
    }
    
    private func performSave() {
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
