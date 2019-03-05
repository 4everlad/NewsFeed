//
//  ImageRequest.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 02/03/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation
import UIKit

class ImageRequest {
    
    static let shared = ImageRequest()
    
    func downloadImage(from url: String, completion: @escaping(UIImage)->()) {
        
        if let imageUrl = URL(string: url) {
            print("Image Download Started")
//            var image: UIImage?
            getData(from: imageUrl, completion: { data, response, error in
                guard let data = data, error == nil else { let image = UIImage(named: "No-images-placeholder")
                    completion(image!)
                    return }
                print(response?.suggestedFilename ?? imageUrl.lastPathComponent)
                print("Image Download Finished")
                if let image = UIImage(data: data){
                    completion(image)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTableView"), object: nil)
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
        
    }
}
