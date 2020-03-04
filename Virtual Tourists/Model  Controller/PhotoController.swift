//
//  PhotoController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/4/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation

class PhotoController {
    //no need for singleton because we are not going to be storing any data and passing it around other views
    static func createPhoto(withImageData data: Data, andWithPin pin: Pin){
        Photo(image: data, pin: pin)
        
        //because Pin is the owner of photos I've decided to go through that to save things to the context
        PinController.shared.saveToPersistentStore()
    }
    
    static func delete(photo: Photo){
        //in the xcdatamodel we set photo's relationship to be nullify which means that it will delete itself from its parent/Pin
        CoreDataStack.shared.mainContext.delete(photo)
        PinController.shared.saveToPersistentStore()
    }
}
