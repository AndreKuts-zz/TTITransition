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
        
        newsDetailsText.clipsToBounds = true
        newsDetailsText.layer.cornerRadius = 10
        guard news != nil, let img = news?.image, let txt = news?.text else { return }
        newsDetailsImage.image = img
        newsDetailsText.text = txt
    }
}
