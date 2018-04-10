//
//  LoadRequest.swift
//  TTITransition
//
//  Created by 1 on 06.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

protocol NewsAPIServiceProtocol : class {
    init(delegate: NewsServiceDelegate?)

    func loadNewsItems(for type: NewsSelection) -> [NewsItem]
    func cancelCurrentDownloading()
}

class NewsAPIService : NewsAPIServiceProtocol {
    private weak var delegate: NewsServiceDelegate?
    
    private var session: URLSession
    private var isCancelled: Bool = false
    
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private let topNews = "/v0/topstories.json"
    private let bestNews = "/v0/beststories.json"
    private let newNews = "/v0/newstories.json"
    private let baseUrl = "https://hacker-news.firebaseio.com"
    
    required init(delegate: NewsServiceDelegate?) {
        self.delegate = delegate
        
        self.session = URLSession.shared
    }
    
    func loadNewsItems(for type: NewsSelection) -> [NewsItem] {
        isCancelled = false
        var getIdsURL = baseUrl
        var result: [NewsItem] = []
        switch type {
        case .best: getIdsURL = "\(baseUrl)\(bestNews)"
        case .new: getIdsURL = "\(baseUrl)\(newNews)"
        case .top: getIdsURL = "\(baseUrl)\(topNews)"
//        default: break
        }
        guard let url = URL(string: getIdsURL) else { return result }
        let retrieveIdsTask = session.dataTask(with: url) {[weak self] (data, response, error) in
            guard let dat = data else { return }
            guard let list = try? JSONDecoder().decode(NewsList.self, from: dat) else { return }
            guard let storngSelf = self else { return }
            result = storngSelf.makeNewsItem(array: list)
        }
        retrieveIdsTask.resume()
        return result
    }
    
    func cancelCurrentDownloading() {
        isCancelled = true
        session.invalidateAndCancel()
    }
    
    private func makeNewsItem(array news: NewsList) -> [NewsItem] {
        let dispathGroup = DispatchGroup()
        var result: [NewsItem] = []
        for i in news.list {
            dispathGroup.enter()
            utilityQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                let urlStr = "\(strongSelf.baseUrl)/v0/item/\(i).json"
                guard let url = URL(string: urlStr) else { return }
                let session = URLSession.shared.dataTask(with: url) { (data, responce, error) in
                    guard let data = data else { return }
                    guard let newsItem = try? JSONDecoder().decode(NewsItem.self, from: data) else {
                        dispathGroup.leave()
                        return
                    }
                    result.append(newsItem)
                    dispathGroup.leave()
                }
                session.resume()
            }
        }
        dispathGroup.notify(queue: .global()) {
            if !self.isCancelled {
                self.delegate?.didNewsItemsArrived(self, news: result)
            }
        }
        return result
    }
}
