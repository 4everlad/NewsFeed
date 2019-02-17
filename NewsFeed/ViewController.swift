//
//  ViewController.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 30/01/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewsFeedUpdateDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    var filteredNewsFeed = [ArticleModel]()
    var resultSearchController = UISearchController()
    
    var newsFeedRequest = NewsFeedRequest.shared
    
    var isSearching : Bool!
    
    
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
            return newsFeedRequest.newsFeed.count
        } else {
            return newsFeedRequest.newsFeed.count
        }
        
        // dataManager.cashedNewsFeed.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (resultSearchController.isActive) {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedTableViewCell
                let article = newsFeedRequest.newsFeed[indexPath.section]
                cell.articleImg = article.image
                cell.title = article.title
                cell.isSeen = article.isSeen
                
                return cell
            
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedNewsFeedCell", for: indexPath) as! DetailedNewsFeedTableViewCell
                
                let article = newsFeedRequest.newsFeed[indexPath.section]
                cell.newsDescription = article.description
                cell.publishedAt = article.publishedAt
                cell.url = article.url
                
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistorySearchTableViewCell", for: indexPath) as! HistorySearchTableViewCell
            
            //let searchResult = cashedNewsFeed
            
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (resultSearchController.isActive) {
            if expandedIndexes.contains(indexPath.section) {
                expandedIndexes.remove(indexPath.section)
                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .automatic)
                tableView.endUpdates()
            } else {
                expandedIndexes.insert(indexPath.section)
                newsFeedRequest.newsFeed[indexPath.section].isSeen = true
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .none)
                tableView.endUpdates()
            }
        } else {
            // newsFeed = cashedNewsFeed[indexPath.section]
            // searchController.searchBar.text
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableView.automaticDimension
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        newsFeedRequest.newsFeed.removeAll()
        expandedIndexes.removeAll()
        
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            
            let performSearch = DispatchWorkItem (qos: .userInteractive, flags:[.enforceQoS]) {
                if searchText == searchController.searchBar.text {
                    var preparedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    preparedSearchText = preparedSearchText.replacingOccurrences(of: " ", with: "+")
                    preparedSearchText = preparedSearchText.lowercased()
                    
                    self.newsFeedRequest.requestNews(keyword: preparedSearchText)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: performSearch)
            
            isSearching = true
            
        } else {
            isSearching = false
            view.endEditing(true)
        }
        
        self.tableView.reloadData()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSearching = false
        
        expandedIndexes = Set<Int>()
        
        newsFeedRequest.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.register(UINib(nibName: "NewsFeedTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NewsFeedCell")
        
        tableView.register(UINib(nibName: "DetailedNewsFeedTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "DetailedNewsFeedCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            controller.searchBar.delegate = self
            
            controller.searchBar.returnKeyType = UIReturnKeyType.done
            
            controller.searchBar.barTintColor = UIColor(red: 61/255.0, green: 172/255.0, blue: 228/255.0, alpha: 1.0)
            
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
            
            controller.searchBar.searchBarStyle = UISearchBar.Style.prominent
            
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
