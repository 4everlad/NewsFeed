//
//  ImageFileManager.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 02/03/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation
import UIKit

class ImageFileManager {
    
    func saveImage(name: String, image: UIImage, completion: ((_ success: Bool, _ error: Error?)->())?) {
        
        let data = image.pngData()
        
        let filename = self.getDocumentsDirectory().appendingPathComponent("\(name).png")
        do {
            try data!.write(to: filename)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadImage(name: String, completion: ((_ success: Bool, _ error: Error?)->())?) -> UIImage? {
        let filename = self.getDocumentsDirectory().appendingPathComponent("\(name).png")
        let image = UIImage(contentsOfFile: filename.path)
        
        return image
    }
    
    func deleteImage(name: String, completion: ((_ success: Bool, _ error: Error?)->())?) {
        let filename = self.getDocumentsDirectory().appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.removeItem(atPath: filename.path)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    init() {
    
    }
}
