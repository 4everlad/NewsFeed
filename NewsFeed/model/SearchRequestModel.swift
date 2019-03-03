//
//  SearchRequestModel.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 20/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import Foundation
import UIKit

class SearchRequestModel {
    
    var text : String
    var date : Date
    
    init(text: String) {
        self.text = text
        date = Date()
    }
}

extension SearchRequestModel: Equatable {
    static func == (lhs: SearchRequestModel, rhs: SearchRequestModel) -> Bool {
        return lhs.text == rhs.text
    }
}

extension SearchRequestModel: Hashable {
    var hashValue: Int {
        return text.hashValue
    }
}
