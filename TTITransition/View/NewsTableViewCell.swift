//
//  NewsTableViewCell.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var iconNews: UIImageView!
    @IBOutlet weak var textNews: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}


extension UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}
