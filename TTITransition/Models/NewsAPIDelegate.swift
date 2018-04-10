//
//  NewsAPIDelegate.swift
//  TTITransition
//
//  Created by 1 on 10.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

protocol NewsServiceDelegate : class {
    func didNewsItemsArrived(_ service: NewsAPIService, news: [NewsItem])
}
