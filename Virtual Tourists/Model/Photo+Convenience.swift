//
//  Photo+Convenience.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/4/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    @discardableResult convenience init(imageData: Data, pin: Pin, context: NSManagedObjectContext =  CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.imageData = imageData
        self.pin = pin
//        self.pin?.photos = image
        //append image to pins
    }
}
