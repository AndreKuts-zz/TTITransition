//
//  NewsList.swift
//  TTITransition
//
//  Created by 1 on 09.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

class NewsList: Codable {
    
    var ids: [Int]
    
    required init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        self.ids = try value.decode([Int].self)
    }
}
