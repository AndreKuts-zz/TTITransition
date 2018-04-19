//
//  NewsAPIServiceProtocol.swift
//  TTITransition
//
//  Created by 1 on 11.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

protocol NewsAPIServiceProtocol : class {
    init(alamofireDelegate: NewsAlamofireServiceDelegate?)
    
    func loadNewsItems(for type: NewsSource, howMuchMore: Int) -> [NewsItem]
    func cancelCurrentDownloading()
}

extension NewsAPIServiceProtocol {
    func loadNewsItems(for type: NewsSource, howMuchMore: Int = 20) -> [NewsItem] {
        return loadNewsItems(for: type, howMuchMore: howMuchMore)
    }
}
