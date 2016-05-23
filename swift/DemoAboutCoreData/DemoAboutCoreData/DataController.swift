//
//  DataController.swift
//  DemoAboutCoreData
//
//  Created by Chung BD on 5/13/16.
//  Copyright © 2016 Chung BD. All rights reserved.
//

import UIKit

import CoreData

class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext

    static let shareInstance = DataController()

    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("Demo", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            /* The directory the application uses to store the Core Data store file.
             This code uses a file named "DataModel.sqlite" in the application's documents directory.
             */
            let storeURL = docURL.URLByAppendingPathComponent("Demo.sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }

    class func saveContextState() -> Void {
        if _dataController.managedObjectContext.hasChanges {
            do {
                try _dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }

    class func createAndSaveWith(userName: String) -> Void {
        let employee = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext:_dataController.managedObjectContext) as! Person
        employee.name = userName

        saveContextState()
    }

    class func deleteObject(with object:NSManagedObject) -> Void {
        _dataController.managedObjectContext.deleteObject(object)
        saveContextState()
    }

    func getAllUserName() -> [AnyObject]? {
        let moc = managedObjectContext
        let employeesFetch = NSFetchRequest(entityName: "Person")

        do {
            let fetchedEmployees = try moc.executeFetchRequest(employeesFetch)
            return fetchedEmployees
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }

        return nil
    }
}
