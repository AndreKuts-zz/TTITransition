//
//  ViewController.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var news: NewsItem? 
    
    @IBOutlet weak var newsDetailsImage: UIImageView!
    @IBOutlet weak var newsDetailsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard news != nil else { return }
        if let img = news?.image {
            newsDetailsImage.image = img
        }
        if let txt = news?.text {
            newsDetailsText.text = txt
        }
    }

}
