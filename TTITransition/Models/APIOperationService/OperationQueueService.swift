//
//  OperationQueueService.swift
//  TTITransition
//
//  Created by 1 on 14.05.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

class NewsOperationQueue: OperationQueue {
    
    private weak var delegate: NewsServiceDelegate?
    
    override init() {
        super.init()
    }
    required init (delegate: NewsServiceDelegate) {
        self.delegate = delegate
    }
    
    
    
    
    
}
