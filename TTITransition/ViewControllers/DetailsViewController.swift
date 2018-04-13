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
    
    var newIconService: NewsIconService!
    var iconData = Data() {
        didSet {
            DispatchQueue.main.async {
                self.newsDetailsImage.image = UIImage(data: self.iconData)
                self.newsDetailsText.text = self.news?.title
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newIconService = NewsIconService(delegate: self)
        rectForTextView()
        guard let news = news else { return }
        newsDetailsText.text = news.title
        guard let url = news.url else { return }
        self.newIconService.allResults(from: url, iconSiteNames: SiteIconName.allValues)
    }
    
    func rectForTextView() {
        backgoundViewForNews.clipsToBounds = true
        backgoundViewForNews.layer.cornerRadius = 10
        newsDetailsText.clipsToBounds = true
        newsDetailsText.layer.cornerRadius = 10
    }
}

extension DetailsViewController: NewsIconLoadDelegate {
    func dataIsCome(_ service: NewsIconService, imageData: Data) {
        self.iconData = imageData
    }
}
