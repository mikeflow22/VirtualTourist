//
//  PhotoRepresentation.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation

struct TopLevelDictionary: Codable {
    let photos: PhotoInformation
}

struct PhotoInformation: Codable {
    let photo: [ PhotoRepresentation ]
}

struct PhotoRepresentation: Codable {
    let id: String
    let owner: String
    let title: String
    let farm: Double
    let secret: String
    let server: String
}
