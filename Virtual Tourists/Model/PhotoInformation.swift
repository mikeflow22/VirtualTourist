//
//  PhotoRepresentation.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation

struct TopLevelDictionary: Codable {
    let photos: PhotoDictionary
}

struct PhotoDictionary: Codable {
    let photo: [ PhotoInformation ]
}

struct PhotoInformation: Codable {
    let id: String
//    let owner: String
//    let title: String
    let farm: Int
    let secret: String
    let server: String
}
