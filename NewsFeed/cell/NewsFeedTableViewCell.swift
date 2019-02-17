//
//  NewsFeedTableViewCell.swift
//  NewsFeed
//
//  Created by Dmitry Bakulin on 01/02/2019.
//  Copyright © 2019 Dmitry Bakulin. All rights reserved.
//

import UIKit

class NewsFeedTableViewCell: UITableViewCell {
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var articleImg: UIImage? {
        didSet {
            articleImage.image = articleImg
        }
    }
    
    var isSeen: Bool! {
        didSet {
            if isSeen {
                isSeenLabel.isHidden = false
            } else {
                isSeenLabel.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var articleImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 0
            titleLabel.sizeToFit()
        }
    }
    
    @IBOutlet weak var isSeenLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
