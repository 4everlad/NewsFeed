//
//  ViewController.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 30/01/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewsFeedUpdateDelegate, UISearchResultsUpdating {
    
    
    var filteredNewsFeed = [ArticleModel]()
    var resultSearchController = UISearchController()
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredNewsFeed.removeAll(keepingCapacity: false)
        
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            filteredNewsFeed.removeAll()
            
            if let newsFeed = newsFeedRequest.newsFeed {
                for index in 0..<newsFeed.count {
                    if newsFeed[index].title!.lowercased().contains(
                        searchText.lowercased()) {
                        filteredNewsFeed.append(newsFeed[index])
                    }
                }
            }
            
        }
        
        self.tableView.reloadData()
    }
    
    
    var newsFeedRequest = NewsFeedRequest.shared
    
    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var expandedIndexes: Set<Int>!

    @IBOutlet weak var tableView: UITableView!
    
    func updateTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !expandedIndexes.contains(section) else {
            return 2
        }
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if  (resultSearchController.isActive) {
            return filteredNewsFeed.count
        } else {
            return newsFeedRequest.newsFeed.count
        }
        
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedTableViewCell
            
            if (resultSearchController.isActive) {
                let article = filteredNewsFeed[indexPath.section]
                cell.articleImg = article.image
                cell.title = article.title
                
                return cell
            } else {
                let article = newsFeedRequest.newsFeed[indexPath.section]
                cell.articleImg = article.image
                cell.title = article.title
                
                return cell
            }
            
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedNewsFeedCell", for: indexPath) as! DetailedNewsFeedTableViewCell
            if (resultSearchController.isActive) {
                let article = filteredNewsFeed[indexPath.section]
                cell.newsDescription = article.description
                cell.publishedAt = article.publishedAt
                cell.url = article.url
                
                return cell
            } else {
                let article = newsFeedRequest.newsFeed[indexPath.section]
                cell.newsDescription = article.description
                cell.publishedAt = article.publishedAt
                cell.url = article.url
                
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndexes.contains(indexPath.section) {
            expandedIndexes.remove(indexPath.section)
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .automatic)
            tableView.endUpdates()
        } else {
            expandedIndexes.insert(indexPath.section)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .automatic)
            tableView.endUpdates()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        expandedIndexes = Set<Int>()
        
        newsFeedRequest.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.register(UINib(nibName: "NewsFeedTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NewsFeedCell")
        
        tableView.register(UINib(nibName: "DetailedNewsFeedTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "DetailedNewsFeedCell")
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    

}

protocol NewsFeedUpdateDelegate {
    func updateTableView()
}
