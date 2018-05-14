//
//  NewsOperationsService.swift
//  TTITransition
//
//  Created by 1 on 14.05.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

class NewsOperation: AsyncOperation {
    
    var newsItem: NewsItem?
    private var urlID: URL?
    
    init (loadItemBy id: String) {
        self.urlID = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")
    }
    
    override func main() {
        guard urlID != nil else { return }
        loadNewsItem(from: urlID!)
    }
    
    func loadNewsItem(from url: URL) {
    
        guard let url = urlID else { return }
        let retrieveIdsTask = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
            guard let data = data,
                let strongSelf = self,
                strongSelf.isCancelled
            else { return }
            strongSelf.newsItem = try? JSONDecoder().decode(NewsItem.self, from: data)
        }
        retrieveIdsTask.resume()
    }
}
