//
//  NewsIcon.swift
//  TTITransition
//
//  Created by 1 on 12.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

class NewsIcon {
    
    private weak var delegateLoadIcon : NewsIconLoadDelegate?
    weak var delegateUpdateIcon: NewsIconUpdateCell?
    private var newsIconService: NewsIconService?
    private var isCancelled: Bool = false
    
    var completion: ((_ data: Data) -> ())?
    var data: Data?
    
    required init (from url: URL?, andDelegegate delegate: NewsIconLoadDelegate?) {
        guard let url = url else { return }
        self.newsIconService = NewsIconService(delegate: self)
        self.delegateLoadIcon = delegate
        self.newsIconService?.allResults(from: url, iconSiteNames: SiteIconName.allValues)
    }
    
    deinit {
        isCancelled = true
        self.newsIconService?.cancelCurrentRequest()
    }
}

extension NewsIcon: NewsIconLoadDelegate {
    func dataIsCome(_ service: NewsIconService, imageData: Data) {
        guard !isCancelled else { return }
        self.completion?(imageData)
        self.data = imageData
    }
}


