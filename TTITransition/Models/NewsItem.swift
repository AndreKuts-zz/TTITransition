//
//  NewsItem.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation
import UIKit



class NewsItem {
    
    let image: UIImage
    let text: String
    
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
    }
}

enum Segment {
    case New, Top, Best
}
