//
//  NewsAlamofireAPIService.swift
//  TTITransition
//
//  Created by 1 on 18.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation
import Alamofire

class NewsAlamofireAPIService: NewsAPIServiceProtocol{
    
    private weak var delegate: NewsAlamofireServiceDelegate?
    
    private let baseUrl = "https://hacker-news.firebaseio.com"
    private let topNews = "/v0/topstories.json"
    private let bestNews = "/v0/beststories.json"
    private let newNews = "/v0/newstories.json"
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    private var isCancelled: Bool = false
    private var howManyIsLoaded = 0
    
    required init(standartDelegate: NewsServiceDelegate?, alamofireDelegat: NewsAlamofireServiceDelegate?) {
        self.delegate = alamofireDelegat
    }
    
    func loadNewsItems(for type: NewsSelection, howMuchMore: Int) -> [NewsItem] {
        isCancelled = false
        
        var getIdsURL = baseUrl
        var result: [NewsItem] = []
        switch type {
        case .best: getIdsURL = "\(baseUrl)\(bestNews)"
        case .new: getIdsURL = "\(baseUrl)\(newNews)"
        case .top: getIdsURL = "\(baseUrl)\(topNews)"
        }
        guard let url = URL(string: getIdsURL) else { return result }
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            guard let data = response.data else { return }
            guard let list = try? JSONDecoder().decode(NewsList.self, from: data) else { return }
            guard list.list.count > howMuchMore else { return }
            if howMuchMore <= self.howManyIsLoaded {
                self.howManyIsLoaded = 0
            }
            let newList = Array(list.list[self.howManyIsLoaded..<howMuchMore])
            self.howManyIsLoaded = howMuchMore
            result = self.makeNewsItem(arrayFrom: newList, rightAmount: howMuchMore)
        })
        return result
    }
    
    private func makeNewsItem(arrayFrom newsID: [Int], rightAmount: Int) -> [NewsItem] {
        let dispathGroup = DispatchGroup()
        var result: [NewsItem] = []
        newsID.forEach { id in
            dispathGroup.enter()
            let urlStr = "\(self.baseUrl)/v0/item/\(id).json"
            utilityQueue.async {
                guard let url = URL(string: urlStr) else {
                    dispathGroup.leave()
                    return
                }
                Alamofire.request(url).responseJSON(completionHandler: { (response) in
                    guard let data = response.data else {
                        dispathGroup.leave()
                        return
                    }
                    guard let newsItem = try? JSONDecoder().decode(NewsItem.self, from: data) else {
                        dispathGroup.leave()
                        return
                    }
                    result.append(newsItem)
                    dispathGroup.leave()
                })
            }
        }
        dispathGroup.notify(queue: .global()) {
            if !self.isCancelled {
                self.delegate?.didNewsItemsArrived(self, news: result)
            }
        }
        return result
    }
    
    func cancelCurrentDownloading() {
    }
}

