//
//  DetailedNewsFeedTableViewCell.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 05/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit

class DetailedNewsFeedTableViewCell: UITableViewCell {
    
    var newsDescription: String? {
        didSet {
            newsDescriptionLabel.text = newsDescription
        }
    }
    
    var publishedAt: Date? {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DDThh:mm"
            publishedAtLabel.text = formatter.string(for: publishedAt)
        }
    }
    
    var url: String? {
        didSet {
            urlLabel.text = url
        }
    }
    
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    
    @IBOutlet weak var publishedAtLabel: UILabel!
    
    @IBOutlet weak var urlLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
