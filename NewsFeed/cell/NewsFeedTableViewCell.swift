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
    
    @IBOutlet weak var articleImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
