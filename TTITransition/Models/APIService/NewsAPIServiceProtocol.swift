//
//  NewsAPIServiceProtocol.swift
//  TTITransition
//
//  Created by 1 on 11.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

protocol NewsAPIServiceProtocol : class {
    init(delegate: NewsServiceDelegate?)
    
    func loadNewsItems(for type: NewsSelection, howMuchMore
: Int) -> [NewsItem]
    func cancelCurrentDownloading()
}

