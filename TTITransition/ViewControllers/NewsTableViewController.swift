//
//  NewsTableViewController.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit


class NewsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var newsTypeSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private let activityIndic = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private let mainQueue = DispatchQueue.main
    
    private var newsService: NewsAPIServiceProtocol!
    private var allIcons: [NewsIcon] = []
    private var allNews: [NewsItem] = [] {
        didSet {
            for i in allNews {
                let itm = NewsIcon(from: i.url, andDelegegate: self)
                itm.delegateUpdateIcon = self
                allIcons.append(itm)
            }

            mainQueue.async {
                self.tableView.reloadData()
                self.switchLoadIndicator()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addActivityIndicator()
        newsService = NewsAPIService(delegate: self)
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        utilityQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .top)
        }
    }
    
    // MARK: ActivityIndicator
    func addActivityIndicator() {
        mainQueue.async {
            self.activityIndic.stopAnimating()
            self.activityIndic.center = self.view.center
            self.view.addSubview(self.activityIndic)
        }
    }
    
    func switchLoadIndicator() {
        mainQueue.async {
            self.activityIndic.isAnimating ? self.activityIndic.stopAnimating() : self.activityIndic.startAnimating()
        }
    }
    
    
    func createdIcons(fromNews: [NewsItem]) {
        
    }
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
        self.switchLoadIndicator()
        self.activityIndic.startAnimating()
        allIcons = []
        switch newsTypeSelector.selectedSegmentIndex {
        case 0:
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .new)
            }
        case 1:
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .top)
            }
        case 2:
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .best)
            }
        default: break
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell () }
        cell.textNews.text = allNews[indexPath.row].title
        
        if !allIcons.isEmpty {
            if let data = allIcons[indexPath.row].data {
                let img = UIImage(data: data)
                cell.iconNews.image = img
            } else {
                let img = UIImage(named: "028-magazine")
                cell.iconNews.image = img
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetails", sender: indexPath)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" ,
            let index = sender as? IndexPath {
            let destVC = segue.destination as? DetailsViewController
            destVC?.news = allNews[index.row]
        }
    }
}

// MARK: - News Icon Service Delegate
extension NewsTableViewController: NewsIconLoadDelegate {
    func dataIsCome(_ service: NewsIconService, imageData: Data) {
        var cout = 0
        for i in allIcons {
            guard let data = i.data,
                data == imageData,
                cout < allIcons.count else {
                    return
            }
            let index = IndexPath(row: cout, section: 0)
            mainQueue.async {
                self.tableView.reloadRows(at: [index], with: .automatic)
            }
            cout += 1
        }
    }
}

extension NewsTableViewController: NewsIconUpdateCell {
    func dataIsCome(_ iconObject: NewsIcon, imageData: Data) {
        var cout = 0
        for icon in allIcons {
            if icon.data != nil {
                guard iconObject === icon && cout < allIcons.count else { return }
                let index = IndexPath(row: cout, section: 0)
                mainQueue.async {
                    self.tableView.reloadRows(at: [index], with: .automatic)
                }
            }
            cout += 1
        }
    }
}



//MARK: - News Service Delegate TableViewController
extension NewsTableViewController : NewsServiceDelegate  {
    func didNewsItemsArrived(_ service: NewsAPIService, news: [NewsItem]) {
        self.allNews = news
        mainQueue.async {
            self.tableView.reloadData()
        }
    }
}

