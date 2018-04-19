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
    @IBOutlet weak var loadingNewNewsIndicator: UIActivityIndicatorView!
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    private var newsSource: NewsSource = .new
    private var newsService: NewsAPIServiceProtocol!
    private var sizeScrollView: CGFloat!
    private var numberNewsUpload = 20
    private var firstLoad = true
    private var isNotDataLoading = false
    private var handlers: [NewsIcon] = []
    private var arrayDownloadedNews: [NewsItem] = [] {
        didSet {
            guard !arrayDownloadedNews.isEmpty else { return }
            createIcons(fromNews: arrayDownloadedNews)
            isNotDataLoading = true
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                var indexes: [IndexPath] = []
                for i in (self.numberNewsUpload - 20)..<self.numberNewsUpload {
                    let index = IndexPath(item: i, section: 0)
                    indexes.append(index)
                }
                self.tableView.insertRows(at: indexes, with: .automatic)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingNewNewsIndicator.isHidden = true
        addActivityIndicator()
        newsService = NewsAlamofireAPIService(alamofireDelegat: self)
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        utilityQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            _ = strongSelf.newsService.loadNewsItems(for: .top, howMuchMore: strongSelf.numberNewsUpload)
        }
    }
    
    // MARK: ActivityIndicator
    func addActivityIndicator() {
        if firstLoad {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.activityIndicator.center = self.view.center
                self.view.addSubview(self.activityIndicator)
            }
            firstLoad = false
        }
    }
    
    func createIcons(fromNews: [NewsItem]) {
        let newNews = Array(arrayDownloadedNews[(numberNewsUpload-20)..<arrayDownloadedNews.count])
        for i in newNews {
            let itm = NewsIcon(from: i.url, andDelegegate: self)
            itm.delegateUpdateIcon = self
            handlers.append(itm)
        }
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
        numberNewsUpload = 20
        handlers = []
        arrayDownloadedNews = []
        isNotDataLoading = false
        tableView.reloadData()
        
        switch newsTypeSelector.selectedSegmentIndex {
        case 0: newsSource = .new
        case 1: newsSource = .top
        case 2: newsSource = .best
        default: break
        }
        utilityQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            _ = strongSelf.newsService.loadNewsItems(for: strongSelf.newsSource, howMuchMore: strongSelf.numberNewsUpload)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDownloadedNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell () }
        if !arrayDownloadedNews.isEmpty {
            cell.lbl.text = arrayDownloadedNews[indexPath.row].title
        }
        let newsIco = NewsIcon(from: arrayDownloadedNews[indexPath.row].url, andDelegegate: nil)
        newsIco.completion = { [unowned self] imgData in
            let img = UIImage(data: imgData)
            DispatchQueue.main.async {
                cell.icon.image = img
            }
            if let index = self.handlers.index(where: { $0 === newsIco }) {
                self.handlers.remove(at: index)
            }
        }
        handlers.append(newsIco)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetails", sender: indexPath)
    }
    
    // MARK: - UITableViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sizeScrollView = scrollView.contentOffset.y + view.frame.height
        if sizeScrollView >= scrollView.contentSize.height - 150 {
            DispatchQueue.main.async {
                guard self.isNotDataLoading else {
                    self.loadingNewNewsIndicator.stopAnimating()
                    self.loadingNewNewsIndicator.isHidden = true
                    return
                }
                self.loadingNewNewsIndicator.startAnimating()
                self.loadingNewNewsIndicator.isHidden = false
            }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.isNotDataLoading {
                    strongSelf.numberNewsUpload += 20
                    let _ = strongSelf.newsService.loadNewsItems(for: strongSelf.newsSource, howMuchMore: strongSelf.numberNewsUpload)
                    strongSelf.isNotDataLoading = false
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" ,
            let index = sender as? IndexPath {
            let destVC = segue.destination as? DetailsViewController
            destVC?.news = arrayDownloadedNews[index.row]
        }
    }
}

// MARK: - NewsIconLoadDelegate
extension NewsTableViewController: NewsIconLoadDelegate {
    func dataIsCome(_ service: NewsIconService, imageData: Data) {
    }
}

// MARK: - NewsIconUpdateCell
extension NewsTableViewController: NewsIconUpdateCell {
    func dataIsCome(_ iconObject: NewsIcon, imageData: Data) {
        DispatchQueue.main.async {
            self.handlers.enumerated().forEach { (offset, newsIcon) in
                guard newsIcon.data != nil, iconObject === newsIcon, offset < self.handlers.count else { return }
                guard offset < self.arrayDownloadedNews.count else { return }
                let index = IndexPath(row: offset, section: 0)
                self.tableView.reloadRows(at: [index], with: .automatic)
            }
        }
    }
}

//MARK: - NewsServiceDelegate
extension NewsTableViewController : NewsServiceDelegate  {
    func didNewsItemsArrived(_ service: NewsAPIService, news: [NewsItem]) {
        DispatchQueue.main.async {
            self.arrayDownloadedNews = self.arrayDownloadedNews + news
        }
    }
}

//MARK: - NewsAlamofireServiceDelegate
extension NewsTableViewController: NewsAlamofireServiceDelegate {
    func didNewsItemsArrived(_ service: NewsAPIServiceProtocol, news: [NewsItem]) {
        DispatchQueue.main.async {
           self.arrayDownloadedNews = self.arrayDownloadedNews + news
        }
    }
}
