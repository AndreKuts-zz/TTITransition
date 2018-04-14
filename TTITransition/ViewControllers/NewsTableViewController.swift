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
    private var contentOfSize: CGFloat = 0
    private var isDataLoading = false
    private var didEndNews: Bool = false
    private var allIcons: [NewsIcon] = []
    private var allNews: [NewsItem] = [] {
        willSet {
            guard newValue.count == allNews.count else { return }
                mainQueue.async {
                    self.loadingNewNewsIndicator.isHidden = true
                }
                isDataLoading = false
        }
        didSet {
            guard !allNews.isEmpty  else { return }
            createdIcons(fromNews: allNews)
            mainQueue.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    private var newsSource: NewsSelection! {
        didSet {
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: strongSelf.newsSource, howMuchMore: strongSelf.numberNewsUpload)
            }
        }
    }
    private var numberNewsUpload = 20 {
        didSet {
            isDataLoading = false
            print(numberNewsUpload)
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
            strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: .top, howMuchMore: strongSelf.numberNewsUpload)
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
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
        allIcons = []
        self.numberNewsUpload = 0
        utilityQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.numberNewsUpload += 20
            strongSelf.allNews = strongSelf.newsService.loadNewsItems(for: strongSelf.newsSource, howMuchMore: strongSelf.numberNewsUpload)
            strongSelf.isDataLoading = true
        }
        switch newsTypeSelector.selectedSegmentIndex {
        case 0: newsSource = .new
        case 1: newsSource = .top
        case 2: newsSource = .best
        default: break
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return allNews.count }
    
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
        contentOfSize = scrollView.contentOffset.y + view.frame.height
        if contentOfSize >= scrollView.contentSize.height - 50 {
            if !isDataLoading {
                isDataLoading = true
                guard isDataLoading else { return }
                mainQueue.async {
                    self.loadingNewNewsIndicator.startAnimating()
                    self.loadingNewNewsIndicator.isHidden = false
                }
                mainQueue.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.numberNewsUpload += 20
                    let newNews = strongSelf.newsService.loadNewsItems(for: .top, howMuchMore: strongSelf.numberNewsUpload)
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
                offset < allIcons.count else { return }
            //            let index = IndexPath(row: offset, section: 0)
            //            mainQueue.async {
            ////                self.tableView.reloadRows(at: [index], with: .automatic)
            //            }
        }
    }
}

// MARK: - News Icon Update Cell
extension NewsTableViewController: NewsIconUpdateCell {
    func dataIsCome(_ iconObject: NewsIcon, imageData: Data) {
        allIcons.enumerated().forEach { (offset, newsIcon) in
            guard newsIcon.data != nil, iconObject === newsIcon, offset > allIcons.count else { return }
            let index = IndexPath(row: offset, section: 0)
            mainQueue.async {
                 self.tableView.reloadRows(at: [index], with: .automatic)
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

