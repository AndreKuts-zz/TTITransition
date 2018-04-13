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
    private var numberNewsUploaded = 0 {
        didSet {
            if numberNewsUploaded <= allNews.count {
                viewIsLoading = false
                print(numberNewsUploaded)
            }
        }
    }
    private var viewIsLoading = false
    private var allIcons: [NewsIcon] = []
    private var allNews: [NewsItem] = [] {
        didSet {
            print(allNews.count)
            createdIcons(fromNews: allNews)
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
            strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .top)
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
            self.tableView.reloadData()
        }
    }
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOfSize = Int(scrollView.contentOffset.y + view.frame.height + 20)
        if contentOfSize > Int(scrollView.contentSize.height) {
            if !viewIsLoading {
                mainQueue.asyncAfter(deadline: .now() + 5, execute: {
                    self.loadingNewNewsIndicator.startAnimating()
                    self.loadingNewNewsIndicator.isHidden = false
                    self.numberNewsUploaded += 20
                    self.tableView.reloadData()
                    print(self.contentOfSize)
                })
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
        self.allNews = news
        mainQueue.async {
            self.tableView.reloadData()
        }
    }
}

