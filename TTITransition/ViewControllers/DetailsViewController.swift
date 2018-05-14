//
//  ViewController.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var news: NewsItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let news = news,
            let url = news.url else {
                return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    deinit {
        webView.stopLoading()
    }
}

