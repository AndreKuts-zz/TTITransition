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
    
    private var newsSource: NewsSelection = .new
    private var newsService: NewsAPIServiceProtocol!
    private var contentOfSize: CGFloat!
    private var numberNewsUpload = 20
    private var isNotDataLoading = false
    private var handlers: [NewsIcon] = []
    private var iconsImageNews: [NewsIcon] = []
    private var arrayDownloadedNews: [NewsItem] = [] {
        willSet {
            guard newValue.count == arrayDownloadedNews.count else { return }
            DispatchQueue.main.async {
                self.loadingNewNewsIndicator.stopAnimating()
                self.loadingNewNewsIndicator.isHidden = true
                
            }
        }
        didSet {
            guard !arrayDownloadedNews.isEmpty else { return }
            createdIcons(fromNews: arrayDownloadedNews)
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
        newsService = NewsAPIService(delegate: self)
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
    
    func createdIcons(fromNews: [NewsItem]) {
        let newNews = Array(arrayDownloadedNews[(numberNewsUpload-20)..<arrayDownloadedNews.count])
        for i in newNews {
            let itm = NewsIcon(from: i.url, andDelegegate: self)
            itm.delegateUpdateIcon = self
            iconsImageNews.append(itm)
        }
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        newsService.cancelCurrentDownloading()
        numberNewsUpload = 20
        iconsImageNews = []
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
    
    // MARK: - Table view data source
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentOfSize = scrollView.contentOffset.y + view.frame.height
        if contentOfSize >= scrollView.contentSize.height - 150 {
            DispatchQueue.main.async {
                guard self.isNotDataLoading else {
                    self.loadingNewNewsIndicator.stopAnimating()
                    self.loadingNewNewsIndicator.isHidden = true
                    return
                }
                self.loadingNewNewsIndicator.startAnimating()
                self.loadingNewNewsIndicator.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
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

// MARK: - News Icon Service Delegate
extension NewsTableViewController: NewsIconLoadDelegate {
    func dataIsCome(_ service: NewsIconService, imageData: Data) {
//        iconsImageNews.enumerated().forEach { (offset, newsIcon) in
//            guard let data = newsIcon.data,
//                data == imageData,
//                offset < iconsImageNews.count else { return }
//            let index = IndexPath(row: offset, section: 0)
//            DispatchQueue.main.async {
//            }
//        }
    }
}

// MARK: - News Icon Update Cell
extension NewsTableViewController: NewsIconUpdateCell {
    func dataIsCome(_ iconObject: NewsIcon, imageData: Data) {
        DispatchQueue.main.async {
            self.iconsImageNews.enumerated().forEach { (offset, newsIcon) in
                guard newsIcon.data != nil, iconObject === newsIcon, offset < self.iconsImageNews.count else { return }
                if offset < self.arrayDownloadedNews.count {
                    let index = IndexPath(row: offset, section: 0)
                    self.tableView.reloadRows(at: [index], with: .automatic)
                }
            }
        }
    }
}

//MARK: - News Service Delegate TableViewController
extension NewsTableViewController : NewsServiceDelegate  {
    func didNewsItemsArrived(_ service: NewsAPIService, news: [NewsItem]) {
        DispatchQueue.main.async {
            self.arrayDownloadedNews = self.arrayDownloadedNews + news
        }
    }
}

