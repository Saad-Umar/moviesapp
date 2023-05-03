//
//  AppPersistenceManager.swift
//  MoviesApp
//
//  Created by Saad Umar on 5/3/23.
//

import CoreData


class AppPersistenceManager:NSObject, PersistenceManager {
    
    static let shared = AppPersistenceManager()
    
    private(set) var container: NSPersistentContainer = NSPersistentContainer(name: "MoviesApp")
    
    /// Initialize a store.
    ///
    /// - Parameters:
    ///     - inMemory: if true, initialize a temporary store for transient data. If false makes a permanent store for persisting data
    override init() {
        super.init()
        
        configureContainer()
        container = NSPersistentContainer(name: "MoviesApp")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func configureContainer() {
        let url = AppURLS.documentsDirectory().appendingPathComponent("movies.sqlite")
        let storeDescription = makeStore(at: url)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { _, error in
            if let error = error {
                print("error: in core data load", error)
            }
            self.container.viewContext.undoManager = UndoManager()
        }
    }
    
    func makeStore(at url: URL) -> NSPersistentStoreDescription {
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.type = NSSQLiteStoreType
        return storeDescription
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        let predicate = NSPredicate(format: "cachedDate < %@", NSDate())
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.container.persistentStoreCoordinator.execute(deleteRequest, with: self.container.viewContext)
        } catch {
            print(error.localizedDescription)
        }
    }
}
