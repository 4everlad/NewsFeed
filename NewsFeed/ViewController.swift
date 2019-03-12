//
//  ViewController.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 30/01/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewsFeedUpdateDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITextViewDelegate {
    
    var dataManager = DataManager.shared
    
    var filteredNewsFeed = [ArticleModel]()
    var resultSearchController = UISearchController()
    
//    var isSearching : Bool!
    
    var expandedIndexes: Set<Int>!

    @IBOutlet weak var tableView: UITableView!
    
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
//        
//        UIApplication.shared.open(URL, options: [:])
//        
//        return true
//    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let latestSearchRequest = dataManager.searchRequest {
            if let newsFeed = dataManager.newsFeed {
                dataManager.updateSearchRequests(searchRequest: latestSearchRequest, newsFeed: newsFeed)
            }
        }
    }
    
    @objc func updateTableView(_ notification: Notification){
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
            return dataManager.newsFeed.count
        }
        else {
            return dataManager.cashedNewsFeeds.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (resultSearchController.isActive) {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedTableViewCell
                let article = dataManager.newsFeed[indexPath.section]
                cell.articleImg = article.image
                cell.title = article.title
                cell.isSeen = article.isSeen
                
                return cell
            
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedNewsFeedCell", for: indexPath) as! DetailedNewsFeedTableViewCell
                
                let article = dataManager.newsFeed[indexPath.section]
                
                cell.newsDescription = article.description
                cell.publishedAt = article.publishedAt
                cell.url = article.url
                
                cell.urlTextView.delegate = self
                
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistorySearchCell", for: indexPath) as! HistorySearchTableViewCell
            
            let searchRequests = Array(dataManager.cashedNewsFeeds.keys)
            
            let sortedSearchRequests = searchRequests.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
            
            let searchRequest = sortedSearchRequests[indexPath.section]
            
            cell.searchRequest = searchRequest.text
            
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
                dataManager.newsFeed[indexPath.section].isSeen = true
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .none)
                tableView.endUpdates()
            }
        } else {
            
            let searchRequests = Array(dataManager.cashedNewsFeeds.keys)
            
            let sortedSearchRequests = searchRequests.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
            
            let selectedSearchRequest = sortedSearchRequests[indexPath.section]
            
            dataManager.newsFeed = dataManager.cashedNewsFeeds![selectedSearchRequest]
            resultSearchController.searchBar.text = selectedSearchRequest.text
            resultSearchController.isActive = true
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableView.automaticDimension
        
    }
    
    
    func prepareText(for text: String) -> String {
        
        var preparedText =  text.trimmingCharacters(in: .whitespacesAndNewlines)
        preparedText = preparedText.replacingOccurrences(of: " ", with: "+")
        preparedText = preparedText.lowercased()
        
        return preparedText
    }
    
    
    func showAlert() {
        let alertController = UIAlertController(title: "Search is only available in English", message:
            "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        if let presentedVC = presentedViewController {
            presentedVC.present(alertController, animated: true, completion: nil)
        } else {
            present(alertController, animated: true, completion: nil)
        }
//        self.present(alertController, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        dataManager.searchRequest = nil
        dataManager.newsFeed.removeAll()
        expandedIndexes.removeAll()
        
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            var text = searchText
            text = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
            
            if text.isAlphanumeric {
//                if let searchText = searchController.searchBar.text,
//                    !searchText.isEmpty {
                
                let performSearch = DispatchWorkItem (qos: .userInitiated, flags:[.enforceQoS]) {
                    if searchText == searchController.searchBar.text {
                        
                        self.dataManager.searchRequest = SearchRequestModel(text: searchText)
                        
                        let preparedSearchText = self.prepareText(for: searchText)
                            
                        self.dataManager.performSearch(searchText: preparedSearchText, completion: { result, error in
                            if result == true {
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            } else if result == false && error != nil {
                                print ("error: \(error)")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        })
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: performSearch)
                    
//                    isSearching = true
                
            } else {
                showAlert()
                searchController.searchBar.text?.removeAll()
                view.endEditing(true)
                
            }
        } else {
//            isSearching = false
            view.endEditing(true)
        }
        
        self.tableView.reloadData()
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        isSearching = false
        
        expandedIndexes = Set<Int>()
        
        dataManager.delegate = self
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.register(UINib(nibName: "NewsFeedTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NewsFeedCell")
        
        tableView.register(UINib(nibName: "DetailedNewsFeedTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "DetailedNewsFeedCell")
        
        tableView.register(UINib(nibName: "HistorySearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "HistorySearchCell")
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView(_:)), name: NSNotification.Name(rawValue: "updateTableView"), object: nil)
        
        tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    

}

protocol NewsFeedUpdateDelegate {
    func updateTableView(_ notification: Notification)
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

//extension ViewController: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
//
//        UIApplication.shared.open(URL, options: [:])
//
//        return true
//    }
//}
