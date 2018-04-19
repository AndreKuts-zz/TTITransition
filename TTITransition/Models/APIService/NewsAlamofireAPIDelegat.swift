//
//  NewsAlamofireAPIDelegat.swift
//  TTITransition
//
//  Created by 1 on 18.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

protocol NewsAlamofireServiceDelegate : class {
    func didNewsItemsArrived(_ service: NewsAPIServiceProtocol, news: [NewsItem])
}
