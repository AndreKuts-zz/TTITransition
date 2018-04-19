
//  NewsItem.swift
//  TTITransition

//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.


import UIKit

class NewsItem: Codable {
    
    let by: String?
    let descendants: String?
    let id: Int?
    let kidsId: [Int]?
    let score: Int?
    let time: Date?
    let title: String
    let type: String?
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case by
        case descendants
        case id
        case kidsId = "kids"
        case score
        case time
        case title
        case type
        case url
    }
    
    //MARK: - Decoder
    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        self.by = try? value.decode(String.self, forKey: .by)
        self.descendants = try? value.decode(String.self, forKey: .descendants)
        self.id = try? value.decode(Int.self, forKey: .id)
        self.kidsId = try? value.decode([Int].self, forKey: .kidsId)
        self.score = try? value.decode(Int.self, forKey: .score)
        self.time = try? value.decode(Date.self, forKey: .time)
        self.title = try value.decode(String.self, forKey: .title)
        self.type = try? value.decode(String.self, forKey: .type)
        self.url = try? value.decode(URL.self, forKey: .url)
        
    }
}
