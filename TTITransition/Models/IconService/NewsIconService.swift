//
//  NewsIconImageService.swift
//  TTITransition
//
//  Created by 1 on 11.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

typealias LoadImageCompletion = (_ imageData: Data?) -> ()

class NewsIconService {
    
    private weak var delegate: NewsIconLoadDelegate?

    private var currentTask: URLSessionDataTask?
    
    static let serverAddressRegexPattern: String = "(?:www\\.)?(.*?)\\.(?:com|au\\.uk|co\\.in)"
    static let siteIconNames: [String] = ["touchicon.ico", "favicon.ico", "touch-icon.ico", "fav-icon.ico"]
    
    private let utilityQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)

    private let dispathGroup = DispatchGroup()
    
    required init (delegate: NewsIconLoadDelegate) {
        self.delegate = delegate
    }
    
    func allResults(from url: URL, iconSiteNames: [SiteIconName]) {
        guard let iconName = iconSiteNames.first,
            let baseUrl = self.returnBaseURL(forRegex: NewsIconService.serverAddressRegexPattern, in: url.absoluteString) else { return }
        let imageURLString = "\(baseUrl)/\(iconName.rawValue)"
        takeFavIcon(from: imageURLString) { [weak self] imageData in
            guard let strongSelf = self else { return }
            guard let imageData = imageData else {
                let newIconNames = Array(iconSiteNames.dropFirst())
                strongSelf.allResults(from: url, iconSiteNames: newIconNames)
                return
            }
            strongSelf.delegate?.dataIsCome(strongSelf, imageData: imageData)
        }
    }
    
    func cancelCurrentRequest() {
        utilityQueue.async {
            self.currentTask?.cancel()
        }
    }
    
    private func returnBaseURL(forRegex: String, in text: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: forRegex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            guard let firstSomething = results.first,
                let fullRange = Range(firstSomething.range, in: text) else { return nil }
            return String(text[fullRange])
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func takeFavIcon(from strUrl: String, completion: @escaping LoadImageCompletion) {
        guard let url = URL(string: strUrl) else {
            completion(nil)
            return
        }
        self.currentTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image") else {
                    return completion(nil)
            }
            completion(data)
        }
        
        utilityQueue.async {
            self.currentTask?.resume()
        }
    }
}

enum SiteIconName: String {
    case touchicon = "touchicon.ico"
    case favicon = "favicon.ico"
    case touch = "touch-icon.ico"
    case fav = "fav-icon.ico"
    
    static let allValues: [SiteIconName] = [.touchicon, .favicon, .touch, .fav]
}
