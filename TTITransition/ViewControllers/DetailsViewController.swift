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
    @IBOutlet weak var backgoundViewForNews: UIView!
    @IBOutlet weak var newsDetailsImage: UIImageView!
    @IBOutlet weak var newsDetailsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgoundViewForNews.clipsToBounds = true
        backgoundViewForNews.layer.cornerRadius = 10
        newsDetailsText.clipsToBounds = true
        newsDetailsText.layer.cornerRadius = 10
        guard let news = news else { return }
//        newsDetailsImage.image = news.image
        newsDetailsText.text = news.title
    }
}
