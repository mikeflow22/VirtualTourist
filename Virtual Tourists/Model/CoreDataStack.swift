//
//  CoreDataStack.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    //step 3: create a container to hold the stack
    let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Flickr")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("unresolved error \(error), \(error.userInfo)")
            }
        })
        
        //because we want to use another context we have to state how we want the two to communicate or work together
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    //step 5 create the context (MOC)
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    //add a save function here for multiple context useage

    func save(context: NSManagedObjectContext) throws {
        var error: Error?
        //try to save on the context that's passed in
        do {
            try context.save()
        } catch let throwError {
            print("Error in: \(#function)\n Readable Error: \(throwError.localizedDescription)\n Technical Error: \(throwError)")
            error = throwError
        }
        if let error = error {
            throw error
        }
        print("saved on another context")
    }
}

