//
//  NewsIconeDelegate.swift
//  TTITransition
//
//  Created by 1 on 11.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//
import Foundation

protocol NewsIconLoadDelegate: class {
    func dataIsCome(_ service: NewsIconService, imageData: Data)
}


protocol NewsIconUpdateCell: class {
    func dataIsCome(_ iconObject: NewsIcon, imageData: Data)
}
