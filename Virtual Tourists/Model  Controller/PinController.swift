//
//  PinController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/4/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import CoreData

class PinController {
    static let shared = PinController()
    
    //this is the data source of truth for all saved model objects
    var pins: [Pin] {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
           let pins = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            return pins
        } catch  {
            print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
            return []
        }
    }
    
    func createPin(withLat lat: Double, andWithlon lon: Double){
        Pin(lat: lat, lon: lon)
        saveToPersistentStore()
    }
    
    func delete(pin: Pin){
        CoreDataStack.shared.mainContext.delete(pin)
        saveToPersistentStore()
    }
    
    
    func saveToPersistentStore(){
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch  {
            print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
        }
    }
}
