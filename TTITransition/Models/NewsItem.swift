//
//  NewsItem.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

class NewsItem {
    
    let image: UIImage
    let text: String
    var isLiked: Bool
    
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
        self.isLiked = false
    }
}

