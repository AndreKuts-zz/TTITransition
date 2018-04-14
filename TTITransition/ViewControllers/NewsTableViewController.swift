//
//  NewsTableViewController.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

private var firstLoad = true

class NewsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var newsTypeSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingNewNewsIndicator: UIActivityIndicatorView!
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private let mainQueue = DispatchQueue.main
    
    private var newsService: NewsAPIServiceProtocol!
    private var contentOfSize = 0
    private var numberNewsUploaded = 20 {
        didSet {
            isDataLoading = false
            print(numberNewsUploaded)
        }
    }
    private var isDataLoading = false {
        didSet {
            
        }
    }
    private var didEndNews: Bool = false
    private var allIcons: [NewsIcon] = []
    private var allNews: [NewsItem] = [] {
        willSet {
            if newValue.count == allNews.count {
                mainQueue.async {
                    self.loadingNewNewsIndicator.isHidden = true
                }
                isDataLoading = false
            }
        }
        
        didSet {
            if !allNews.isEmpty {
                mainQueue.async {
                    self.activityIndicator.stopAnimating()
                }
            }
//            createdIcons(fromNews: allNews)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingNewNewsIndicator.isHidden = true
        addActivityIndicator()
        newsService = NewsAPIService(delegate: self)
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        utilityQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .top, howMuchMore
: strongSelf.numberNewsUploaded)
        }
    }
    
    
    
    // MARK: ActivityIndicator
    func addActivityIndicator() {
        if firstLoad {
            mainQueue.async {
                self.activityIndicator.startAnimating()
                self.activityIndicator.center = self.view.center
                self.view.addSubview(self.activityIndicator)
            }
            firstLoad = false
        }
    }
    
    func switchLoadIndicator() {
        mainQueue.async {
            self.activityIndicator.isAnimating ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
        }
    }
    
    func createdIcons(fromNews: [NewsItem]) {
        for i in allNews {
            let itm = NewsIcon(from: i.url, andDelegegate: self)
            itm.delegateUpdateIcon = self
            allIcons.append(itm)
        }
        mainQueue.async {
            if !self.allNews.isEmpty {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
        allIcons = []
        numberNewsUploaded = 20
        switch newsTypeSelector.selectedSegmentIndex {
        case 0:
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .new, howMuchMore
: strongSelf.numberNewsUploaded)
            }
        case 1:
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .top, howMuchMore
: strongSelf.numberNewsUploaded)
            }
        case 2:
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .best, howMuchMore
: strongSelf.numberNewsUploaded)
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
        
        if !allNews.isEmpty {
            cell.textNews.text = allNews[indexPath.row].title
        }

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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOfSize = Int(scrollView.contentOffset.y + view.frame.height + 50)
        if contentOfSize >= Int(scrollView.contentSize.height) {
            if !isDataLoading {
                isDataLoading = true
                guard isDataLoading else { return }
                mainQueue.async {
                    self.loadingNewNewsIndicator.startAnimating()
                    self.loadingNewNewsIndicator.isHidden = false
                }
                mainQueue.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.numberNewsUploaded += 20
                    let newNews = strongSelf.newsService.loadNewsItems(for: .top, howMuchMore
: strongSelf.numberNewsUploaded)
                    strongSelf.allNews = strongSelf.allNews + newNews
                }
            }
        }
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
        allIcons.enumerated().forEach { (offset, newsIcon) in
            guard let data = newsIcon.data,
                data == imageData,
                offset < allIcons.count else { return}
            let index = IndexPath(row: offset, section: 0)
            mainQueue.async {
                self.tableView.reloadRows(at: [index], with: .automatic)
            }
        }
    }
}

extension NewsTableViewController: NewsIconUpdateCell {
    func dataIsCome(_ iconObject: NewsIcon, imageData: Data) {
        allIcons.enumerated().forEach { (offset, newsIcon) in
            guard newsIcon.data != nil,
                iconObject === newsIcon,
                offset < allIcons.count else { return}
            let index = IndexPath(row: offset, section: 0)
            mainQueue.async {
                if offset < self.allIcons.count  {
                    self.tableView.reloadRows(at: [index], with: .automatic)
                }
            }
        }
    }
}

//MARK: - News Service Delegate TableViewController
extension NewsTableViewController : NewsServiceDelegate  {
    func didNewsItemsArrived(_ service: NewsAPIService, news: [NewsItem]) {
        self.allNews = self.allNews + news
        mainQueue.async {
            self.tableView.reloadData()
        }
    }
}

