//
//  Pin+Convenience.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/4/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
extension Pin {
    @discardableResult convenience init(lat: Double, lon: Double, photos: [Photo] = []/*, coordinate: CLLocationCoordinate2D? = nil*/, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.lat = lat
        self.lon = lon
        
        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
        }
    }
}
