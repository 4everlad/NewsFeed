//
//  HistorySearchTableViewCell.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 16/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit

class HistorySearchTableViewCell: UITableViewCell {
    
    var searchRequest: String? {
        didSet {
            searchRequestLabel.text = searchRequest
        }
    }
    
    @IBOutlet weak var searchRequestLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
