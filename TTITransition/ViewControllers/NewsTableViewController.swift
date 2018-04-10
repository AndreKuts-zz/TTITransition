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
    
    private var activityIndic = UIActivityIndicatorView()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private let main = DispatchQueue.main
    private var newsService: NewsAPIServiceProtocol!
    private var allNews: [NewsItem] = [] {
        didSet {
            main.async {
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
        main.async {
            self.activityIndic = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            self.activityIndic.stopAnimating()
            self.activityIndic.center = self.view.center
            self.view.addSubview(self.activityIndic)
        }
    }
    
    func switchLoadIndicator() {
        main.async {
            self.activityIndic.isAnimating ? self.activityIndic.stopAnimating() : self.activityIndic.startAnimating()
        }
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
        self.switchLoadIndicator()
        self.activityIndic.startAnimating()
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

//MARK: - News Service Delegate TableViewController
extension NewsTableViewController : NewsServiceDelegate  {
    func didNewsItemsArrived(_ service: NewsAPIService, news: [NewsItem]) {
        self.allNews = news
        main.async {
            self.tableView.reloadData()
        }
    }
}
