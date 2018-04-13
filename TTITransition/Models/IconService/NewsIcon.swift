//
//  NewsIconUpdate.swift
//  TTITransition
//
//  Created by 1 on 12.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation


class NewsIcon {
    
    var data: Data?
    
    private var newsIconService: NewsIconService?
    
    private weak var delegateLoadIcon : NewsIconLoadDelegate?
    weak var delegateUpdateIcon: NewsIconUpdateCell?
    
    required init (from url: URL?, andDelegegate delegate: NewsIconLoadDelegate?) {
        guard let url = url else { return }
        self.newsIconService = NewsIconService(delegate: self)
        self.delegateLoadIcon = delegate
        self.newsIconService?.allResults(from: url, iconSiteNames: SiteIconName.allValues)
    }
}

extension NewsIcon: NewsIconLoadDelegate {
    func dataIsCome(_ service: NewsIconService, imageData: Data) {
        self.data = imageData
        delegateUpdateIcon?.dataIsCome(self, imageData: imageData)
    }
}


